<div align="right">

English | [简体中文](README.zh-CN.md)

</div>

## Phro's goal is to become a <span style="color:#2196F3"><strong>powerful</strong></span> & <span style="color:#2196F3"><strong>easy-to-use</strong></span> Agent assistant.

## Project Philosophy

### Simplicity is the only path to real strength.
### Focus on high-difficulty & high-value features, building barriers with dedication  
### Identify essential capabilities — no fluff, no trend-chasing.

## Planning & Progress

| Status | Capability                                                                      |
| ------ | ------------------------------------------------------------------------------- |
| ✅      | Agent Loop and common tools (local file editing, shell command execution, etc.) |
| ✅      | Human-in-the-loop                                                               |
| ✅      | Custom Agents                                                                   |
| ✅      | Local file create/read/update/delete                                            |
| ✅      | Web search                                                                      |
| ❌      | Multi-Agent collaboration and planning execution                                |
| ❌      | Office file processing                                                          |
| ❌      | Mobile device automation control                                                |
| ❌      | Browser automation control                                                      |
| ❌      | Multimodal                                                                      |

## Usage Guide

### Language Model Configuration Required:
![image](docs/_assets/README/language_model_config.png)
Recommended free model: Zhipu's [glm-4.7-flash](https://bigmodel.cn/).  
Most platforms offer free models or sign-up bonuses — too many to list.

### For web search capability, configure a Search API.
Currently supports [Tavily](https://www.tavily.com/) and [FireCrawl](https://www.firecrawl.dev/), both with monthly free quotas.

## Development Environment Setup

The project is built with Flutter to easily support both desktop and mobile platforms.  
First install the Flutter SDK. Refer to the [official Flutter installation guide](https://docs.flutter.dev/install).

```bash
flutter pub get
flutter run
```
For mobile development, please install Android Studio and configure the Android environment and emulator by yourself.

## User Support
Contact WeChat: xdu11117  
Or email: 2321409910@qq.com

## License

Apache-2.0