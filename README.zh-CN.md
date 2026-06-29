  
<div align="right">

[English](README.md) | 简体中文

</div>

## Phro 的目标是成为一个 <span style="color:#2196F3"><strong>强大</strong></span> & <span style="color:#2196F3"><strong>易用</strong></span> 的Agent助手。

## 项目哲学

### 简单是通往强大的唯一途径  
### 聚焦高难度&高价值的功能，用心血构造壁垒  
### 识别本质能力，不包装，不跟风

## 规划与进展

| 状态 | 能力                                                |
| ---- | --------------------------------------------------- |
| ✅    | Agent Loop与常见工具(本地文件修改、shell命令执行等) |
| ✅    | Human-in-the-loop                                   |
| ✅    | 自定义 Agent                                        |
| ✅    | 本地文件增删改查                                    |
| ✅    | 联网搜索                                            |
| ❌    | 多 Agent 协作与规划执行                             |
| ❌    | Office 文件处理                                     |
| ❌    | 移动设备自动化控制                                  |
| ❌    | 浏览器自动化控制                                    |
| ❌    | 多模态                                              |

## 使用指导

### 语言模型必须配：
![image](docs/_assets/README/language_model_config.png)
免费模型推荐智谱的[glm-4.7-flash](https://bigmodel.cn/)。  
各大平台都有免费模型/注册薅羊毛，不一一列举

### 如需联网搜索能力，需配置搜索 API。
目前支持[Tavily](https://www.tavily.com/)、[FireCrawl](https://www.firecrawl.dev/)，每月有免费额度。  

## 开发环境配置

项目使用 Flutter 开发，主要是为了更方便地覆盖桌面端与移动端。  
需要先安装 Flutter 环境，具体可以参考 [Flutter 官方安装文档](https://docs.flutter.dev/install)。

```bash
flutter pub get
flutter run
```
移动端开发请自行安装Android Studio并配置安卓环境以及虚拟机



## License

Apache-2.0
   