# 构建：使用golang:1.13.4版本
FROM golang:1.13.4 as build

# 容器环境变量添加
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn,direct

# 设置当前工作区
WORKDIR /go/release

# 把全部文件添加到/go/release目录
ADD . .

# 编译: 把main.go编译为可执行的二进制文件, 并命名为app
RUN GOOS=linux CGO_ENABLED=0 GOARCH=amd64 go build -ldflags="-s -w" -installsuffix cgo -o app main.go

# 运行: 使用scratch作为基础镜像
FROM scratch as prod

# 在build阶段, 复制时区配置到镜像的/etc/localtime
COPY --from=build /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 在build阶段, 复制./app目录下的可执行二进制文件到当前目录
COPY --from=build /go/release/app /

# 暴露9000端口
EXPOSE 9000

# 启动服务
CMD ["/app"]
