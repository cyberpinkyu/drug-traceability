# 项目部署说明

本项目已**移除 iOS 平台**，仅保留 Android / Web / Windows / Linux / macOS 端。

## 一、后端服务部署（推荐：Docker Compose）

### 前置要求：安装 Docker（Windows）

若提示“无法将 docker 项识别为……”说明尚未安装或未加入 PATH：

1. 下载并安装 **Docker Desktop for Windows**：  
   https://docs.docker.com/desktop/install/windows-install/
2. 安装完成后**重启电脑**（或至少重启 PowerShell）。
3. 打开 PowerShell 或 CMD，执行 `docker --version` 和 `docker compose version` 确认可用。

Docker Desktop 已内置 Compose，使用子命令 **`docker compose`**（有空格，无连字符）即可。

### 一键启动

在项目根目录执行（任选其一）：

```bash
docker compose up -d
```

若为旧版独立安装的 Compose，则使用：

```bash
docker-compose up -d
```

将启动：

- **MySQL**：端口 3306，数据库 `drug_traceability`，root 密码 `root`
- **Redis**：端口 6379
- **RabbitMQ**：端口 5672，管理界面 http://localhost:15672（guest/guest）
- **Spring Boot 后端**：http://localhost:8080

### 仅启动中间件（本地运行后端）

若希望在本机用 IDE 运行后端，只启动数据库与中间件：

```bash
docker compose up -d mysql redis rabbitmq
```

然后在本机配置 `drug-traceability/src/main/resources/application.yml` 中的地址为 `localhost`，运行 Spring Boot 应用。

---

## 二、移动端（Flutter）构建

### Android APK

```bash
cd drug-traceability-app
flutter pub get
flutter build apk --release
```

产物路径：`build/app/outputs/flutter-apk/app-release.apk`。

#### 若报错：NDK 没有 source.properties 或下载卡住

构建需要 Android NDK，若提示 `NDK at ... did not have a source.properties file` 或一直停在 “Preparing Install NDK…”：

1. **推荐：用 Android Studio 安装 NDK**  
   打开 Android Studio → **设置/Setting** → **Languages & Frameworks** → **Android SDK** → 切到 **SDK Tools** → 勾选 **NDK (Side by side)** → 应用并等待安装完成。  
   若已勾选仍报错，可先取消勾选应用一次，再重新勾选安装。

2. **或删除损坏的 NDK 后重新构建**（让 Gradle 自动下载）：  
   删除目录：`%LOCALAPPDATA%\Android\sdk\ndk\28.2.13676358`（或报错里提示的路径），然后重新执行 `flutter build apk --release`。  
   首次自动下载可能较慢（约 1GB），需保持网络畅通。

#### 若报错：Not in GZIP format / SDK 管理器安装 NDK 失败

本机从 `dl.google.com` 下载 NDK 常会失败（返回非压缩包导致 “Not in GZIP format”）。本项目已固定使用 **NDK 27.0.12077973**，可改为**国内镜像手动安装**：

1. **下载 NDK 27（任选一个能打开的链接）**  
   - 腾讯云：`https://mirrors.cloud.tencent.com/android/repository/android-ndk-r27-windows.zip`  
   - 或官方（需网络通畅）：`https://dl.google.com/android/repository/android-ndk-r27-windows.zip`

2. **解压并放到 SDK 的 ndk 目录**  
   - 解压 zip，得到文件夹（通常名为 `android-ndk-r27`）。  
   - 将该文件夹**内部的全部内容**（含 `source.properties`、`toolchains` 等）复制到：  
     `%LOCALAPPDATA%\Android\sdk\ndk\27.0.12077973\`  
   - 若 `ndk\27.0.12077973` 不存在，请先新建该文件夹再粘贴。  
   - 确认路径下有文件：`ndk\27.0.12077973\source.properties`。

3. **重新构建**  
   ```bash
   cd drug-traceability-app
   flutter clean
   flutter build apk --release
   ```

### 其他平台

- **Web**：`flutter build web`，将 `build/web` 部署到任意静态站点。
- **Windows**：`flutter build windows`。
- **macOS**：`flutter build macos`（仅 macOS 主机）。

---

## 三、前端 Web（若有）

若使用 `drug-traceability-frontend`：

```bash
cd drug-traceability-frontend
npm ci
npm run build
```

将 `dist`（或配置的构建输出目录）部署到 Nginx / 对象存储 / 静态托管即可。

---

## 四、生产环境注意

1. **敏感信息**：修改 MySQL、Redis、RabbitMQ 的默认密码，并通过环境变量或 `application-prod.yml` 配置，不要提交到仓库。
2. **AI 能力**：若使用 DeepSeek、Milvus 等，在 `application.yml` 或环境变量中配置 `ai.deepseek.api-key` 及 Milvus 连接信息。
3. **HTTPS**：对外服务建议用 Nginx/Caddy 做反向代理并配置 SSL。

---

## 五、已移除内容

- 项目内 **iOS** 相关目录与配置已删除，仅保留 Android 及其他平台。
