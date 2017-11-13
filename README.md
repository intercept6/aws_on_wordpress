# AWS On WordPress

## 概要

- AWS上にWordPressを構築
- Load Balancerを使用してWebサーバを冗長化
- マルチAZを使用してDBを冗長化
- terraformを使用

## 構成

![構成図](https://github.com/kmd2kmd/aws_on_wordpress/images.diagram.png)

### 手順

```bash s
git clone https://github.com/kmd2kmd/aws_on_wordpress
cd aws_on_wordpress
terraform init
terraform plan
terraform apply
```

## 参考サイト

- [ACMで取得した証明書をterraformで配置する - tjinjin's blog](http://cross-black777.hatenablog.com/entry/2016/11/17/231733)
- [TerraformでRDSを構築するぞ - tjinjin's blog](http://cross-black777.hatenablog.com/entry/2016/04/13/233208)
- [AWSでTerraformに入門 ｜ Developers.IO](https://dev.classmethod.jp/cloud/terraform-getting-started-with-aws/)
- [Setting up IPv6 on Amazon with Terraform – Mattias Holmlund – Medium](https://medium.com/@mattias.holmlund/setting-up-ipv6-on-amazon-with-terraform-e14b3bfef577)
