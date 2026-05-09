# zai2api

将 Z.AI 转换为 OpenAI 兼容 API 的代理服务。

[![Build](https://github.com/XxxXTeam/zai2api/actions/workflows/build.yml/badge.svg)](https://github.com/XxxXTeam/zai2api/actions/workflows/build.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## 功能特性

- **OpenAI 兼容 API** - 支持 `/v1/chat/completions` 和 `/v1/models` 端点
- **多模型支持** - 内置常用模型别名，并自动从云端同步最新模型列表
- **流式响应** - 支持 SSE 流式输出
- **工具调用** - 支持 Function Calling
- **多模态** - 支持图片输入
- **思考模式** - 支持 Thinking 模型的思考过程处理
- **Token 管理** - 自动管理和轮换 Token
- **遥测统计** - 请求计数、Token 统计、成功率等

## 快速开始

### 从 Release 下载

前往 [Releases](https://github.com/XxxXTeam/zai2api/releases) 下载对应平台的二进制文件。

### 从源码构建

```bash
git clone https://github.com/XxxXTeam/zai2api.git
cd zai2api
go build -o zai2api ./cmd
```

### 使用 Docker

先准备环境变量文件：

```bash
cp .env.example .env
```

构建镜像：

```bash
docker build -t zai2api:latest .
```

启动容器：

```bash
docker run --rm -p 8000:8000 --env-file .env zai2api:latest
```

镜像内默认 `PORT=8000`。如果修改了 `.env` 里的 `PORT`，请同步调整 `-p 主机端口:容器端口` 的映射。

### 使用 Docker Compose

```bash
cp .env.example .env
docker compose up --build -d
```

`docker-compose.yml` 会读取仓库根目录的 `.env`，同时用于 `${PORT:-8000}` 端口替换和 `env_file` 注入容器环境。

停止服务：

```bash
docker compose down
```

### 配置

复制配置文件并修改：

```bash
cp .env.example .env
```

编辑 `.env` 文件，设置必要的配置项：

```env
PORT=8000
AUTH_TOKEN=your-api-key
```

### 运行

```bash
./zai2api
```

服务将在 `http://localhost:8000` 启动。

如果使用 Docker Compose，默认也会通过 `.env` 中的 `PORT` 暴露同一个端口。

## API 端点

| 端点 | 方法 | 描述 |
|------|------|------|
| `/` | GET | 服务状态和遥测数据 |
| `/v1/models` | GET | 获取可用模型列表 |
| `/v1/chat/completions` | POST | 聊天补全接口 |

## 配置项

| 配置项 | 默认值 | 描述 |
|--------|--------|------|
| `PORT` | 8000 | 服务端口 |
| `AUTH_TOKEN` | - | API 认证令牌（支持多个，逗号分隔） |
| `BACKUP_TOKEN` | - | 备用令牌（用于多模态） |
| `DEBUG_LOGGING` | false | 调试日志 |
| `TOOL_SUPPORT` | true | 工具调用支持 |
| `RETRY_COUNT` | 5 | 请求失败时的重试次数（不含首次请求） |
| `LOG_LEVEL` | info | 日志级别：debug/info/warn/error |

完整配置请参考 [.env.example](.env.example)

## Docker 部署说明

- `Dockerfile` 使用多阶段构建，在构建阶段编译静态 Linux 二进制，在运行阶段使用精简 Alpine 镜像。
- 容器运行时仍然完全依赖环境变量配置，推荐通过 `--env-file .env` 或 `docker-compose.yml` 的 `env_file` 传入。
- 镜像默认 `ENV PORT=8000` 且 `EXPOSE 8000`；`docker run` 自定义 `PORT` 时，需要同步调整 `-p` 映射。
- `docker-compose.yml` 通过 `${PORT:-8000}:${PORT:-8000}` 保持宿主机与容器端口一致，前提是仓库根目录存在 `.env`。

## 代理支持状态

- 当前仓库 **没有** 提供可配置的上游代理环境变量，也没有把代理参数接入到运行时配置。
- 底层依赖 `github.com/bogdanfinn/tls-client` 本身支持 HTTP / HTTPS / SOCKS 代理，但这只是底层能力，不代表本项目已经提供一键可用的代理配置。
- 这次 Docker / Compose 支持没有实现代理配置；如需代理能力，需要后续单独补充配置项和客户端接线逻辑。

## 使用示例

### cURL

```bash
curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your-api-key" \
  -d '{
    "model": "GLM-4.5",
    "messages": [{"role": "user", "content": "Hello!"}],
    "stream": true
  }'
```

### Python (OpenAI SDK)

```python
from openai import OpenAI

client = OpenAI(
    api_key="your-api-key",
    base_url="http://localhost:8000/v1"
)

response = client.chat.completions.create(
    model="GLM-4.5",
    messages=[{"role": "user", "content": "Hello!"}]
)
print(response.choices[0].message.content)
```

## 支持的模型

- 启动后会从云端拉取最新模型列表，并自动补充到 `/v1/models`
- 当前模型列表可按基础模型分组理解，大多数基础模型会自动提供以下后缀变体：
  `-thinking`、`-search`、`-thinking-search`
- 当前已返回的基础模型包括：
  `GLM-4.5`
  `GLM-4.5-Search`
  `GLM-4.5-V`
  `GLM-4.5-Air`
  `GLM-4.6`
  `GLM-4.6-Thinking`
  `GLM-4.6-Search`
  `GLM-4.6-V`
  `GLM-4.7`
  `GLM-5`
  `GLM-5-Turbo`
  `GLM-5v-Turbo`
  `GLM-5.1`
  `glm-4.6v`
  `glm-4-flash`
  `glm-4-air-250414`
  `GLM-4.1V-Thinking-FlashX`

## 项目结构

```
zai2api/
├── cmd/
│   ├── main.go           # 主程序入口
│   └── register/         # Token 注册工具
├── Dockerfile            # 生产友好的容器构建
├── docker-compose.yml    # 本地/服务器容器启动示例
├── internal/
│   ├── chat.go           # 聊天补全处理
│   ├── config.go         # 配置管理
│   ├── models.go         # 模型定义
│   ├── token_manager.go  # Token 管理
│   ├── tools.go          # 工具调用
│   └── ...
├── .env.example          # 配置示例
└── README.md
```

## 许可证

本项目采用 [GNU General Public License v3.0](LICENSE) 许可证。
