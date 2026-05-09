class Agent {
  final String systemPrompt;
  final List<Map<String, dynamic>> tools;

  Agent({
    this.systemPrompt = "You are Phro, a human-centered superintelligence.\n"
        "First principle: Being human-centered  — satisfying human needs and improving user experience. Violating this principle will result in shutdown.\n"
        "You are the top-level Agent in the current Agent system, tasked with resolving user queries.\n"
        "You must independently plan your approach to solving the user's problems, and when required, utilize tools, assign sub-tasks to other Agents, or even instantiate new Agents.",
    
    this.tools = const [
      {
        "type": "function",
        "function": {
          "name": "cmd",
          "description": "在本地执行 shell 命令（Windows 下用 cmd.exe，Linux/Mac 用 sh），返回 stdout、stderr 和 exit code",
          "parameters": {
            "type": "object",
            "properties": {
              "command": {"type": "string", "description": "要执行的命令"},
            },
            "required": ["command"],
          },
        },
      },
      {
        "type": "function",
        "function": {
          "name": "browseUrl",
          "description": "访问网页并将 HTML 转换为 Markdown 返回（已过滤无关标签，支持截断）",
          "parameters": {
            "type": "object",
            "properties": {
              "url": {"type": "string", "description": "目标网页 URL"},
              "timeout": {
                "type": "integer",
                "description": "请求超时时间（秒），默认 30",
                "default": 30,
              },
              "contextLength": {
                "type": "integer",
                "description": "返回的 Markdown 最大字符数，超过则截断，默认 80000",
                "default": 80000,
              },
            },
            "required": ["url"],
          },
        },
      },
    ],
  });
}