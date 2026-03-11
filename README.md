## Bracket

一款基于 Flutter 的免费观影 App

> A video App based on Flutter

<img style="margin-right: 10px" src="https://img.shields.io/badge/dart-v3.3.4%20(stable)-blue"> <img style="margin-right: 10px"  src="https://img.shields.io/badge/flutter-v3.19.6-red"> <img 
style="margin-right: 10px" src="https://img.shields.io/badge/fvm-v3.1.7-yellow">

## Film data source

本项目通过[Bracket-Film](https://github.com/fe-spark/Bracket-Film)接入数据，如需搭建视频源，可自行搭建[Bracket-Film](https://github.com/fe-spark/Bracket-Film)

[网页版观影地址](https://film.fe-spark.cn/)

## Getting Started

```
f run
```

## Build

IOS(无企业签名，请自行签名)

```
f build ipa
```

ADNDROID

```
f build apk
```

本项目已配置 GitHub Actions 自动化打包，支持 APK 和 IPA 输出。

- **自动触发**：创建并推送以 `v` 开头的标签（如 `v1.4.1`）时自动构建
- **手动触发**：在 GitHub 仓库的 Actions 页面点击 `Run workflow` 手动触发
- **下载产物**：构建完成后，在 Actions 运行记录中下载 `bracket-release-apk` 或 `bracket-release-ipa`
- **自动发布**：推送 `v*` 标签时，APK 和 IPA 会自动附加到 GitHub Release

## Preview

<table>
  <tr>
      <td>
         <img width="250px" src="./preview/推荐.png">
      </td>
      <td>
         <img width="250px" src="./preview/分类.png">
      </td>
      <td>
         <img width="250px" src="./preview/我的.png">
      </td>
      <td>
         <img width="250px" src="./preview/筛选.png">
      </td>
      <td>
         <img width="250px" src="./preview/播放页.png">
      </td>
   </tr>
</table>

## Matters needing attention

关于影视源问题

> 提供官方免费源`https://film.fe-spark.cn/api/`(末尾可不带`/`), 由于服务器带宽较低，经常访问失败，还请谅解，如需搭建视频源，可自行搭建[Bracket-Film](https://github.com/fe-spark/Bracket-Film)。

## Write at the end

> 免责声明：数据来源均来自于网络，暂不提供下载功能，本项目仅供学习交流，如有侵权，可通过邮箱联系我
