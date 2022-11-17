#!/bin/bash
# create k8s certs.
# author: LiJinzhu

get_base_dir=/usr/local/src
ssl_base_dir=/etc/kubernetes/pki
current_path=`pwd`


#准备自签证书环境
# cfssl version=v1.6.1
certificate(){
	echo "进入下载目录/usr/local/src:"
	cd $get_base
	sleep 1
	echo "下在下载cfssl证书工具："
	wget https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssljson_1.6.1_linux_amd64
	wget https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssl_1.6.1_linux_amd64
	wget https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssl-certinfo_1.6.1_linux_amd64
	sleep 1
	echo "生成cfssl证书工具(cfssl、cfssl-certinfo、cfssljson)"
	mv cfssl_1.6.1_linux_amd64 /usr/bin/cfssl
	mv cfssl-certinfo_1.6.1_linux_amd64 /usr/bin/cfssl-certinfo
	mv cfssljson_1.6.1_linux_amd64 /usr/bin/cfssljson
	chmod 755 /usr/bin/cfssl*
}


# 创建CA
create_ca(){
	echo "创建证书及CA所在目录"
	test -d $ssl_base_dir && echo "目录已存在" || mkdir -pv $ssl_base_dir
	cd $ssl_base_dir
	sleep 1
	echo "正在生成："
	/usr/bin/cfssl gencert -initca ${current_path}/k8s-certs/ca-csr.json | cfssljson -bare ca
	cp ${current_path}/k8s-certs/ca-config.json $ssl_base_dir
	sleep 1
	echo "创建CA完成."

}

# 生成etcd证书
create_etcd(){
	echo "正在生成etcd的证书和私钥,请稍候......"
	sleep 1
	# 分发etcd的证书请求
	/bin/cp ${current_path}/k8s-certs/etcd-csr.json ${ssl_base_dir}
	cd $ssl_base_dir
	/usr/bin/cfssl gencert \
			-ca=${ssl_base_dir}/ca.pem \
			-ca-key=${ssl_base_dir}/ca-key.pem \
			-config=${ssl_base_dir}/ca-config.json \
			-profile=kubernetes ${current_path}/k8s-certs/etcd-csr.json | /usr/bin/cfssljson -bare etcd
}

# 生成kube-apiserver证书
create_apiserver(){
	echo "正在生成kube-apiserver的证书和私钥,请稍候......"
	sleep 1
	# 分发kube-apiserver的证书请求
	/bin/cp ${current_path}/k8s-certs/kube-apiserver-csr.json ${ssl_base_dir}
	cd $ssl_base_dir
	/usr/bin/cfssl gencert \
			-ca=${ssl_base_dir}/ca.pem \
			-ca-key=${ssl_base_dir}/ca-key.pem \
			-config=${ssl_base_dir}/ca-config.json \
			-profile=kubernetes ${current_path}/k8s-certs/kube-apiserver-csr.json | /usr/bin/cfssljson -bare kube-apiserver
}
#certificate
#create_ca
create_etcd
create_apiserver
