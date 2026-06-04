#import "template.typ": *

#show: doc => template("开发 - 让 OJ “听见”", doc, bibliography_src: none)

= 背景

我已担任三年《基于 Python 的游戏程序设计》课程助教。其中，我出过的最得意的一个作业题就是用 pygame 演奏校歌。这不是音频播放那么简单的事情，而是需要自己从简谱到十二平均律，从音高到简谐运动，一步步合成校歌的旋律。我相当喜欢这个题目，这个题目也延续了三年。

第一年，因为我才疏学浅，不通乐理，给出的简谱到频率的换算漏洞百出，导致学生合成的校歌相当难听。遗憾的是，也没有通乐理的同学来提醒我这一点。第二年，我认真学习了十二平均律，换算仍存在小问题，但大体旋律没问题。不过，很多学生仍然合成出了不太好听的校歌。今年，我终于把换算问题彻底解决了，给了更好的提示，还提示给每个音符添加淡入淡出，学生们合成的校歌也大有改观。今年学生作业的改观，或许更大的原因是 AI 发展，完成这样一个作业已经不是很困难了。

言归正传，我一直希望能够自动完成对学生合成音乐的评测。特别是第一年，学生的合成校歌非常难听的时候，为它们评分极大摧残了我的精神。但不知为何，每年到校庆附近，我都会变得异常忙碌。今年，在完成毕业论文的间隙，我终于有机会实现这个自动评测系统了。

= 题目（校歌演奏）

#import "@preview/cmarker:0.1.8"
#import "@preview/mitex:0.2.6": mitex

#rect(inset: 1em, radius: 0.6cm)[
#cmarker.render(read("problem.md"), math: mitex,   scope: (image: (source, alt: none, format: auto) => image(source, alt: alt, format: format)))
]
= 评测框架

== 人工评测框架

为了这门课程，我已经对 dotOJ 进行了魔改，添加了人工评测这一题型。人工评测题是丑陋的，是违背 Online Judge 美学的，但它确实更加灵活。在用户提交代码之后，系统会发送邮件给管理员。管理员用一个脚本运行这个提交，输入得分，脚本把得分提交到系统里，并发邮件通知用户。

为了隔离学生提交的代码，我使用 Docker，并让 Docker 支持了图形界面。我使用的是 `archlinux` 的基础镜像，安装了 `weston` 并使用 `vnc` 模式运行，在宿主机上使用 `tigervnc` 连接到 Docker 里。`Weston` 的妙处在于，它是基于 Wayland 的，并且支持硬件加速。

下面是我使用的基础的 Dockerfile，对于不同题目，我会在这个基础上安装不同的依赖。


```Dockerfile
FROM archlinux:base-devel-20260329.0.507017

WORKDIR /workspace

RUN pacman -Syyu --noconfirm && pacman -S --noconfirm --needed \
    weston \
    xorg-xwayland \
    wayland \
    wayland-protocols \
    xorg-xclock \
    wayland-utils \
    neatvnc \
    ttf-dejavu \
    ttf-liberation \
    noto-fonts \
    noto-fonts-cjk \
    noto-fonts-emoji \
    libdisplay-info && \
    pacman -Scc --noconfirm

ENV XDG_RUNTIME_DIR=/tmp/runtime-root
ENV WAYLAND_DISPLAY=wayland-0
ENV DISPLAY=:0

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANGUAGE=en_US:en

RUN mkdir -p /etc/ssl/private /etc/ssl/certs && \
    openssl genrsa -out /etc/ssl/private/tls.key 2048 && \
    openssl req -new -key /etc/ssl/private/tls.key -out /etc/ssl/private/tls.csr -subj "/CN=localhost" && \
    openssl x509 -req -days 365 -signkey /etc/ssl/private/tls.key \
    -in /etc/ssl/private/tls.csr -out /etc/ssl/certs/tls.crt

RUN mkdir -p ~/.config && \ 
    cat <<EOF > ~/.config/weston.ini 
[core]
shell=desktop
xwayland=true
backend=vnc
idle-time=0

[vnc]
tls-key=/etc/ssl/private/tls.key
tls-cert=/etc/ssl/certs/tls.crt

[output]
name=vnc
mode=800x600
resizable=true
EOF

RUN mkdir -p /tmp/runtime-root && chmod 700 /tmp/runtime-root &&\
    mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

RUN cat <<EOF > /etc/pam.d/weston-remote-access
auth    required    pam_permit.so
account required    pam_permit.so
session required    pam_permit.so
EOF

EXPOSE 5905
CMD ["weston", "--socket=wayland-0", \
    "--config=/root/.config/weston.ini", "--backend=vnc", "--address=0.0.0.0", "--port=5905"]
```

== 音频评测框架

尽管 dotOJ 的评测功能非常强大，用它评测音频还是过于麻烦。我选择继续利用人工评测接口，在此基础上实现自动评测。即评测机假装是我本人，自动运行学生的代码，但自动给出得分。这样做的好处是，不需要去和 `ioi/isolate` 斗智斗勇。

要让评测机“听见”，首先需要一个声卡。我选择使用 `pipewire` 上的 `loopback` 模块，实现一个回环的虚拟声卡。学生代码自动使用这个声卡的虚拟扬声器播放，评测机自动从这个声卡的虚拟麦克风录音。

下面是我评测音频使用的 Dockerfile，在之前的基础上安装了 `pipewire` 和相关组件，并且配置了一个回环的虚拟声卡。

```dockerfile
FROM weston:arch

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm --needed \
        base-devel \
        python \
        python-pip \
        python-pygame \
        tk \
        python-numpy \
        pipewire pipewire-audio wireplumber alsa-utils dbus rtkit pipewire-alsa pipewire-pulse 

RUN mkdir -p /run/dbus
RUN dbus-uuidgen --ensure=/etc/machine-id

ENV XDG_RUNTIME_DIR=/tmp/runtime
RUN mkdir -p $XDG_RUNTIME_DIR && chmod 700 $XDG_RUNTIME_DIR

# 2. Tell PipeWire to explicitly fallback to standard scheduling if RTKit fails
ENV PIPEWIRE_LATENCY="256/48000"

RUN mkdir -p /root/.config/pipewire/pipewire.conf.d
COPY virtual-sink.conf /root/.config/pipewire/pipewire.conf.d/virtual-sink.conf
COPY record.sh /record.sh
RUN chmod +x /record.sh

CMD ["sh", "-c", "dbus-daemon --system --fork --print-pid --print-address && \
                  /usr/lib/rtkit-daemon & \
                  eval $(dbus-launch --sh-syntax) && pipewire & sleep 3 && wireplumber & sleep 3 && pipewire-pulse & sleep 3 && /record.sh python /judge/source.py"]
```

下面是我的 pipewire 虚拟声卡配置文件 `virtual-sink.conf`。

```conf
context.modules = [
{   name = libpipewire-module-loopback
    args = {
        node.description = "Virtual Loopback"
        #target.delay.sec = 1.5
        capture.props = {
            node.name = "virtual-speaker"
            media.class = "Audio/Sink"
            audio.position = [ FL FR ]
        }
        playback.props = {
            node.name = "virtual-microphone"
            media.class = "Audio/Source"
            audio.position = [ FL FR ]
            node.passive = true
            audio.channels = 2
        }
    }
}
]
```

以及脚本 `record.sh`，它会按照传入参数运行学生代码，并且在此期间录音。

```bash
#!/bin/bash

# 固定的第二个程序
prog2="pw-record --rate 48000 --channels 2 --format f32 --raw /out/recording.pcm"

# 启动第一个程序（用户输入）
"$@" &
pid1=$!

# 启动第二个程序（固定）
eval "$prog2" &
pid2=$!

# 等待第一个程序结束
wait $pid1

kill $pid2 2>/dev/null
```

录制产生的音频文件是一个原始的 PCM 文件，采样率为 48000 Hz，双声道，每个样本 32 位浮点数。也就是，每 8 个字节对应 $1/48000$ 秒时的振动位置，前 4 个字节是左声道，后 4 个字节是右声道，每 4 个字节是一个 $0$ 到 $1$ 之间的浮点数，表示振动位置。

= 评测方法

我的评测是以傅立叶变换为基础的。我没有学过傅立叶变换，只学过傅立叶级数，做过很多把周期函数分解成一系列正弦函数和的微积分题目。我还在算法导论上读到过，离散傅立叶变换可以做多项式乘积的快速计算，但算法导论是从多项式插值的角度来讲的。之前电子学院的选修课上我还了解过，傅立叶变换可以把时域信号变换到频域。但我一直没有明白，傅立叶级数、傅立叶变换、多项式积和信号处理四者的关系。

经过后续学习，我了解到，傅立叶变换就是把傅立叶级数推广到非周期函数；离散傅立叶变换是对连续傅立叶变换的离散化。多项式的积只是傅立叶变换的一个应用场景，它和信号处理也是统一的，因为时域上的卷积就是频域上的内积，只是多项式乘积还有一步逆变换，把结果从频域变回时域。

我把录音切割成 50ms 的小段，再重复一遍。重复一遍的目的是为了增加频域上的分辨率。每一段做傅立叶变换，然后找频域上的最大值，作为主要频率。取最大值的方法可能不是最好的，可能取频域上前几个峰值的加权平均会更好，但我还是懒惰地选择了取最大值的方法。

```rust
pub fn process_block(
    buffer: &[u8],
    bytes_read: usize,
    fft: &dyn rustfft::Fft<f32>,
) -> (String, f32, f32, String, f32, f32) {
    let (left, right): (Vec<f32>, Vec<f32>) = buffer[..bytes_read * 2]
        .chunks_exact(NUM_CHANNELS as usize * BYTES_PER_SAMPLE as usize)
        .map(|chunk| {
            let left_sample = f32::from_le_bytes(chunk[0..4].try_into().unwrap());
            let right_sample = f32::from_le_bytes(chunk[4..8].try_into().unwrap());
            (left_sample, right_sample)
        })
        .unzip();

    let mut left_spectrum = left
        .iter()
        .map(|&s| Complex::new(s, 0.0))
        .collect::<Vec<_>>();
    let mut right_spectrum = right
        .iter()
        .map(|&s| Complex::new(s, 0.0))
        .collect::<Vec<_>>();

    fft.process(&mut left_spectrum);
    fft.process(&mut right_spectrum);

    let left_spectrum = left_spectrum
        .into_iter()
        .map(|c| c.norm())
        .take(LEN_SPECTRUM)
        .collect::<Vec<_>>();
    let right_spectrum = right_spectrum
        .into_iter()
        .map(|c| c.norm())
        .take(LEN_SPECTRUM)
        .collect::<Vec<_>>();

    let left_major = left_spectrum
        .iter()
        .enumerate()
        .max_by(|a, b| a.1.partial_cmp(b.1).unwrap())
        .map(|(i, _)| i)
        .unwrap_or(0);
    let right_major = right_spectrum
        .iter()
        .enumerate()
        .max_by(|a, b| a.1.partial_cmp(b.1).unwrap())
        .map(|(i, _)| i)
        .unwrap_or(0);

    let left_freq: f32 = left_major as f32 * SAMPLE_RATE as f32 / (SAMPLES_PER_BLOCK as f32 * 2.0);
    let right_freq: f32 =
        right_major as f32 * SAMPLE_RATE as f32 / (SAMPLES_PER_BLOCK as f32 * 2.0);

    let left_frac = left_spectrum[0isize.max(left_major as isize - 100) as usize
        ..=(LEN_SPECTRUM - 1).min(left_major + 100)]
        .iter()
        .sum::<f32>()
        / left_spectrum.iter().sum::<f32>();
    let right_frac = right_spectrum[0isize.max(right_major as isize - 100) as usize
        ..=(LEN_SPECTRUM - 1).min(right_major + 100)]
        .iter()
        .sum::<f32>()
        / right_spectrum.iter().sum::<f32>();

    let left_note = if left_frac > 0.1 {
        freq_to_jianpu(left_freq as f64)
    } else {
        "0".to_string()
    };
    let right_note = if right_frac > 0.1 {
        freq_to_jianpu(right_freq as f64)
    } else {
        "0".to_string()
    };

    return (
        left_note,
        if left_frac > 0.1 { left_freq } else { 0.0 },
        left_frac,
        right_note,
        if right_frac > 0.1 { right_freq } else { 0.0 },
        right_frac,
    );
}
```

上面的代码虽然丑，但有效，就是计算每一段的主要频率，以及它 $plus.minus 100$ 范围内的频率占总频率的比例。最后，如果这个比例超过 $0.1$，就认为这个段有这个频率的音符，否则认为没有。

我使用简谱和十二平均律计算每个音的理论频率，并通过重复来使得标准频率序列和实际频率序列对齐。对于频率我定义了距离函数

$
  "dist" (f_1, f_2) = cases(
    0 "if" f_1 = f_2 = 0,
    6 "if" f_1 = 0 xor f_2 = 0,
    abs(log_2(f_1 / f_2)) dot.op bb(1)[log_2(f_1 / f_2) > 0.5] "otherwise"
  )
$

即距离定义为半音的倍数。如果一个有音而一个没有，则距离固定为 6；如果不超过 0.5 个半音，就忽略误差；超过 0.5 个半音，就按照半音的倍数来计算距离。

然后，我使用 DTW（Dynamic Time Warping）算法来计算实际频率序列和标准频率序列的距离。它的定义是

#algorithm(
  caption: "Two Sum Problem",
  pseudocode-list([
    - *Input*: Source sequence $S$ of length $n$, target sequence $T$ of length $m$, distance function $"dist"$.
    - *Output*: Distance between $S$ and $T$.
    - *let* $"DTW" := "array" [0..n, 0..m] "with inintial value" infinity$
    - *for* $i$ *in* $[n]$ *do* 
      - *for* $j$ *in* $[m]$ *do* 
        - $"cost" <- "dist"(S[i], T[j])$
        - $"DTW"[i, j] <- "cost" + min("DTW"[i-1, j], "DTW"[i, j-1], "DTW"[i-1, j-1])$
    - *return* $"DTW"[n, m]$
  ]),
)

这是编辑距离的变种，区别是编辑距离考察的是增加、替换、删除的次数，而 DTW 的增加、替换、删除代价不计，考虑的是最优匹配下的距离总和。

将 DTW 距离处以小段的个数，得到平均每段的距离，记作 $d$，并令 $d = min(d, 6)$。

此外，对于噪声强度过高的，也要做出惩罚。噪声的计算方式如下。

#codly(languages: codly-languages)
```rust
let noise = input_spectrum.iter().zip(input_frac.iter())
  .map(|(f, frac)| 
    if *f > 0.0 {
      (0.5f32 - *frac).clamp(0f32, 0.4f32) * (1.0 / 0.4) 
    } else {
      0.0f32 
    })
  .sum::<f32>() / input_spectrum.iter().filter(|&&f| f > 0.0).count() as f32;
```

即一个音的频谱中，主要频率（包含邻域）的占比为 $p$ 的话，那噪声等级就是 $(0.5 - p) times 2.5$，即当 $p$ 超过 $0.5$ 时，不惩罚；当 $p$ 低于 $0.1$ 时，认为没有这个音，而刚好 $p$ 为 $0.1$ 时，惩罚达到最大值 $1$。最后把所有音的噪声等级取平均，得到整体的噪声等级 $n$。

最后，得分定义为 $min{100, (102 - 100 times d / 6) times (1 - n)}$。也就是说，DTW 距离越大，得分越低；噪声等级越高，得分越低。对于 DTW 距离，有一定的容错率；对于噪声等级，因为强度不足 0.5 才惩罚，所以没有容错率。

这样，一个判题器就完成了。它的输入是一个音频文件，输出是一个分数。

我还在其中使用了 `rayon` 来并行化，并行化的粒度是一个 50 ms 的小段。并行对速度的提升非常大。

= 评测服务

剩下的问题，就是轮询服务器是否有新提交，有新提交就运行，最后把得分提交到系统里。

为了提高评测速度，我还进行了任务级的并行化。我使用了 Producer-Consumer 模式，Producer 负责轮询服务器，将新的提交放入一个任务队列；Consumer 负责从任务队列里取出任务，运行评测器，提交得分。

= Bugs

无法避免的，评测机会出现一些 bug。首先的一个 bug 是，我的 Producer 从服务器获取任务是无状态的，所以它可能会重复获取同一个任务，导致同一个提交被评测多次。我选择复辟“等待队列”这一状态，作为标记。当 Producer 获取到一个新任务时，它会把这个任务的状态改为“等待队列”，然后放入任务队列里。

随之而来的问题是，一次提交学生会收到三次邮件通知，进入等待队列一次，开始运行一次，完成一次，修复方法是显而易见的。

第三个问题是，我愚蠢的忽略了 token 过期的问题，导致评测服务在运行一段时间后就无法获取新任务了。修复方法也是显而易见的。

对于一些玄学性的问题，我选择每小时重启一次评测服务。这样，评测服务已经稳定地运行了两周多了。

= 代码

完整代码见 #link("https://git.nju.edu.cn/cpl-team/dotoj-njuse/-/tree/add-manual-judge/AdminCliTools/environments/audio")[dotoj-njuse/AdminCliTools/environments/audio]。