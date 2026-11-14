# 1. Infrastructure Specification

| 항목 | 값 |
|---|---|
| 상태 | Approved |
| 버전 | 1.0 |
| 날짜 | 2026-11-14 |
| 작성자 | 박가온누리 |
| 아키텍처 기준 | docs/architecture.md(v1.3), images/architecture-v1.0.png |
| 요구사항 기준 | docs/context.md(v1.0) |
| 결정 기준 | docs/ai-decision.md(D-001 ~ D-053) |

## 1.1 문서 목적
- 이 문서는 승인된 architecture.md를 Terraform으로 구현하기 위한 유일한 인프라 명세다(CLAUDE.md §4).
- AWS 리소스별 설정값을 YAML로 정의한다.
- 엔지니어가 승인하기 전까지 이 명세를 기준으로 Terraform을 구현하지 않는다.

## 1.2 표기 규칙
- `미확정(U-xx)`: 결정되지 않은 값이다. §6 미확정 사항의 ID를 가리킨다. 엔지니어가 결정하기 전까지 Terraform 구현을 시작하지 않는다.
- `# D-xxx`: 값의 근거가 된 결정 ID(docs/ai-decision.md)다.
- `# AWS 제약`: 아키텍처 결정이 아니라 AWS 또는 Terraform Provider의 동작 때문에 필요한 값이다.
- `managed_by: terraform`: Terraform이 생성하는 리소스다.
- `managed_by: manual`: 엔지니어가 수동으로 구성한다. Terraform은 생성하지 않으며, 수동 작업의 참고용으로만 기재한다.
- YAML 키(예: `private-app`)는 이 명세 안에서 리소스를 가리키는 논리 이름이다. AWS 리소스 이름은 각 리소스의 `name`(RDS는 `identifier`, ElastiCache는 `replication_group_id`) 값을 사용한다. 리소스에 이름 인자가 없으면 `name` 값을 `Name` 태그로 설정한다.


# 2. 공통 설정

```yaml
Common:
  region: ap-northeast-2
  environment: prod                  # context.md 1.2
  terraform_state: local             # context.md 1.2
  terraform_version: 1.17.2
  aws_provider_version: 6.71.0
  naming_convention: 
    pattern: "{project}-{environment}-{resource}-{role}"
    project: commerce
    environment: prod
  default_tags:
    project: commerce
    environment: prod
    managedBy: terraform
  unspecified_arguments:
    optional_arguments: omit # 명세에 없는 선택 인자는 Terraform 코드에 작성하지 않습니다.
    defaults: provider_or_aws # 생략된 인자는 Terraform Provider 또는 AWS의 기본 동작을 따릅니다.
    security_sensitive_arguments: require_explicit_value # 보안에 영향을 주는 값은 명시적으로 정의해야 합니다.
    architecture_affecting_arguments: require_explicit_value # 네트워크 구성이나 리소스 동작에 영향을 주는 값은 명시적으로 정의해야 합니다.
    missing_required_decisions: stop_and_ask # 중요한 설정이 누락되었다면 Claude Code가 임의로 결정하지 않고 엔지니어에게 질문합니다.
```


# 3. 관리 범위

## 3.1 리소스 수량

| 구분 | 리소스 | 수량 | 관리 |
|---|---|---|---|
| Network | VPC | 1 | terraform |
| Network | Subnet | 8 | terraform |
| Network | Internet Gateway | 1 | terraform |
| Network | NAT Gateway | 1 | terraform |
| Network | Elastic IP | 2 (NLB 1, NAT Gateway 1) | terraform |
| Network | Route Table | 3 (public, private-app, private-local) | terraform |
| Security | Security Group | 7 | terraform |
| Load Balancing | NLB | 1 | terraform |
| Load Balancing | NLB Listener | 1 | terraform |
| Load Balancing | NLB Target Group (ALB 대상) | 1 | terraform |
| Load Balancing | NLB Target Group에 ALB 등록 | 1 | manual |
| Load Balancing | ALB | 1 | terraform |
| Load Balancing | ALB HTTPS Listener | 1 | manual |
| Load Balancing | ALB Listener Rule (Host 기반) | 3 | manual |
| Load Balancing | ALB Target Group | 3 | manual |
| DNS | Route 53 Public Hosted Zone | 1 | terraform |
| DNS | Route 53 Alias 레코드 | 3 | manual |
| DNS | registrar NS 위임 | 1 | manual |
| Certificate | ACM 인증서 | 1 | terraform |
| Certificate | ACM DNS 검증 CNAME | - | manual |
| Compute | Key Pair (기존 리소스 이름 참조) | 3 | manual |
| Compute | EC2 (admin, b2b, b2c, log, bastion) | 5 | terraform |
| Database | DB Subnet Group | 1 | terraform |
| Database | DB Parameter Group | 1 | terraform |
| Database | RDS for MySQL Instance | 1 | terraform |
| Cache | ElastiCache Subnet Group | 1 | terraform |
| Cache | ElastiCache Redis (replication group) | 1 | terraform |
| CI/CD | S3 Bucket (배포 아티팩트) | 1 | terraform |
| CI/CD | CodeDeploy Application | 1 | terraform |
| CI/CD | CodeDeploy Deployment Group | - | manual |
| IAM | Instance Profile, CodeDeploy Service Role, GitHub Actions 인증 | - | manual |

## 3.2 리소스 네이밍

- 명명 규칙: `{project}-{environment}-{resource}-{role}` (§2 `naming_convention`)
- `명세 키`는 §4 YAML에서 해당 리소스를 가리키는 키다.
- 이름 인자가 없는 리소스는 `Name` 태그로 설정한다(§1.2).
- 이름이 정해지지 않은 수동 구성 리소스는 `미확정`으로 표기한다.

### 3.2.1 Terraform 관리 리소스

| 리소스 | 명세 키 | 리소스 이름 |
|---|---|---|
| VPC | `main` | `commerce-prod-vpc-main` |
| Subnet | `public-bastion` | `commerce-prod-subnet-public-bastion` |
| Subnet | `public-nlb` | `commerce-prod-subnet-public-nlb` |
| Subnet | `private-alb-a` | `commerce-prod-subnet-private-alb-a` |
| Subnet | `private-alb-c` | `commerce-prod-subnet-private-alb-c` |
| Subnet | `private-app` | `commerce-prod-subnet-private-app` |
| Subnet | `private-redis` | `commerce-prod-subnet-private-redis` |
| Subnet | `private-rds-a` | `commerce-prod-subnet-private-rds-a` |
| Subnet | `private-rds-c` | `commerce-prod-subnet-private-rds-c` |
| Internet Gateway | `main` | `commerce-prod-igw-main` |
| Elastic IP | `nat` | `commerce-prod-eip-nat` |
| Elastic IP | `nlb` | `commerce-prod-eip-nlb` |
| NAT Gateway | `main` | `commerce-prod-nat-main` |
| Route Table | `public` | `commerce-prod-rt-public` |
| Route Table | `private-app` | `commerce-prod-rt-private-app` |
| Route Table | `private-local` | `commerce-prod-rt-private-local` |
| Security Group | `nlb-sg` | `commerce-prod-sg-nlb` |
| Security Group | `alb-sg` | `commerce-prod-sg-alb` |
| Security Group | `app-sg` | `commerce-prod-sg-app` |
| Security Group | `loki-sg` | `commerce-prod-sg-loki` |
| Security Group | `bastion-sg` | `commerce-prod-sg-bastion` |
| Security Group | `rds-sg` | `commerce-prod-sg-rds` |
| Security Group | `redis-sg` | `commerce-prod-sg-redis` |
| NLB | `nlb` | `commerce-prod-nlb-public` |
| NLB Listener | `nlb-443` | `commerce-prod-listener-nlb-443` |
| NLB Target Group | `nlb-tg-alb` | `commerce-prod-tg-nlb-alb` |
| ALB | `alb` | `commerce-prod-alb-internal` |
| Route 53 Hosted Zone | `imcommerce` | `imcommerce.shop` (태그: `commerce-prod-zone-imcommerce`) |
| ACM 인증서 | `imcommerce` | `commerce-prod-acm-imcommerce` |
| EC2 | `admin` | `commerce-prod-ec2-admin` |
| EC2 | `b2b` | `commerce-prod-ec2-b2b` |
| EC2 | `b2c` | `commerce-prod-ec2-b2c` |
| EC2 | `log` | `commerce-prod-ec2-log` |
| EC2 | `bastion` | `commerce-prod-ec2-bastion` |
| DB Subnet Group | `rds` | `commerce-prod-dbsubnet-rds` |
| DB Parameter Group | `mysql` | `commerce-prod-dbparam-mysql80` |
| RDS Instance | `mysql` | `commerce-prod-rds-mysql` |
| ElastiCache Subnet Group | `redis` | `commerce-prod-cachesubnet-redis` |
| ElastiCache Replication Group | `redis` | `commerce-prod-redis-main` |
| S3 Bucket | `artifact` | `commerce-prod-codedeploy-artifacts` |
| CodeDeploy Application | - | `commerce-prod-codedeploy-cd` |

### 3.2.2 수동 관리 리소스

| 리소스 | 리소스 이름 | 비고 |
|---|---|---|
| Key Pair | `commerce-prod-app-key` | 기존 리소스, admin·b2b·b2c가 참조 |
| Key Pair | `commerce-prod-log-key` | 기존 리소스, log가 참조 |
| Key Pair | `commerce-prod-bastion-key` | 기존 리소스, bastion이 참조 |
| Route 53 Alias 레코드 | `admin.imcommerce.shop` | 레코드 이름 = 도메인 |
| Route 53 Alias 레코드 | `b2b.imcommerce.shop` | 레코드 이름 = 도메인 |
| Route 53 Alias 레코드 | `b2c.imcommerce.shop` | 레코드 이름 = 도메인 |
| ALB HTTPS Listener | 미확정 | |
| ALB Listener Rule (3) | 미확정 | |
| ALB Target Group (3) | 미확정 | |
| NLB Target Group에 ALB 등록 | 미확정 | |
| registrar NS 위임 | 미확정 | |
| ACM DNS 검증 CNAME | 미확정 | |
| CodeDeploy Deployment Group | 미확정 | |
| IAM (Instance Profile, CodeDeploy Service Role, GitHub Actions 인증) | 미확정 | |

## 3.3 Terraform 범위에서 제외되는 항목
- AWS IAM 전체 (D-017)
- ALB HTTPS Listener, Listener Rule, ALB Target Group, NLB Target Group에 ALB 등록 (D-035, D-042)
- Route 53 Alias 레코드, registrar NS 위임 (D-032)
- ACM DNS 검증 CNAME (D-037)
- CodeDeploy Deployment Group (D-021), CodeDeploy Agent 설치 (D-020)
- Alloy label 설정 (D-018)
- GitHub Actions (architecture.md REQ-05)


# 4. 리소스별 명세

## 4.1 Network

```yaml
VPC:
  main:
    managed_by: terraform
    name: commerce-prod-vpc-main
    cidr_block: 192.168.0.0/24          # 아키텍처 다이어그램

Subnet:                                 # D-019, D-043, D-044
  public-bastion:
    managed_by: terraform
    name: commerce-prod-subnet-public-bastion
    cidr_block: 192.168.0.0/27
    availability_zone: ap-northeast-2a
    type: public
    map_public_ip_on_launch: true
    hosts: [bastion, nat-gateway]

  public-nlb:
    managed_by: terraform
    name: commerce-prod-subnet-public-nlb
    cidr_block: 192.168.0.128/27
    availability_zone: ap-northeast-2a  # D-012 (ALB Subnet AZ 중 하나)
    type: public
    hosts: [nlb]

  private-alb-a:
    managed_by: terraform
    name: commerce-prod-subnet-private-alb-a
    cidr_block: 192.168.0.64/27
    availability_zone: ap-northeast-2a
    type: private
    hosts: [alb]

  private-alb-c:
    managed_by: terraform
    name: commerce-prod-subnet-private-alb-c
    cidr_block: 192.168.0.224/27
    availability_zone: ap-northeast-2c  # AWS 제약: ALB는 2개 이상 AZ의 Subnet 필요
    type: private
    hosts: [alb]

  private-app:
    managed_by: terraform
    name: commerce-prod-subnet-private-app
    cidr_block: 192.168.0.32/27
    availability_zone: ap-northeast-2a
    type: private
    hosts: [admin, b2b, b2c, log]       # D-009, D-019

  private-redis:
    managed_by: terraform
    name: commerce-prod-subnet-private-redis
    cidr_block: 192.168.0.160/27
    availability_zone: ap-northeast-2a
    type: private
    hosts: [redis]

  private-rds-a:
    managed_by: terraform
    name: commerce-prod-subnet-private-rds-a
    cidr_block: 192.168.0.192/27
    availability_zone: ap-northeast-2a
    type: private
    hosts: [rds]

  private-rds-c:
    managed_by: terraform
    name: commerce-prod-subnet-private-rds-c
    cidr_block: 192.168.0.96/27
    availability_zone: ap-northeast-2c  # D-008, D-019
    type: private
    hosts: [rds]

InternetGateway:
  main:
    managed_by: terraform
    name: commerce-prod-igw-main
    vpc: main

ElasticIP:
  nat:
    managed_by: terraform
    name: commerce-prod-eip-nat
    domain: vpc
    attached_to: nat-gateway            # AWS 제약: public NAT Gateway는 EIP 필요
  nlb:
    managed_by: terraform
    name: commerce-prod-eip-nlb
    domain: vpc
    attached_to: nlb (subnet_mapping, public-nlb)  # REQ-01 고정 Public IP

NATGateway:
  main:
    managed_by: terraform
    name: commerce-prod-nat-main
    count: 1
    connectivity_type: public
    subnet: public-bastion              # 아키텍처 다이어그램
    eip: nat

RouteTable:
  public:
    managed_by: terraform
    name: commerce-prod-rt-public
    routes:
      - destination: 0.0.0.0/0
        target: internet-gateway
    associations: [public-bastion, public-nlb]

  private-app:
    managed_by: terraform
    name: commerce-prod-rt-private-app
    routes:
      - destination: 0.0.0.0/0
        target: nat-gateway             # D-004 (앱 서버, 로그 서버 outbound)
    associations: [private-app]

  private-local:
    managed_by: terraform
    name: commerce-prod-rt-private-local
    routes: []                          # local 경로(192.168.0.0/24)만 사용. 0.0.0.0/0 경로 없음 (U-04 결정)
    associations: [private-alb-a, private-alb-c, private-redis, private-rds-a, private-rds-c]
```

## 4.2 Security Group
SG egress는 아래 YAML에 정의된 규칙만 허용한다(D-046). Terraform `aws_security_group`은 기본 egress를 제거하므로 egress 규칙을 명시적으로 생성하며, `rds-sg`·`redis-sg`는 egress 규칙을 두지 않는다.

```yaml
SecurityGroup:
  nlb-sg:                               # D-013, D-022
    managed_by: terraform
    name: commerce-prod-sg-nlb
    attached_to: [nlb]
    ingress:
      - protocol: tcp
        port: 443
        source: 0.0.0.0/0
    egress:
      - protocol: tcp
        port : 443
        destination: alb-sg          # D-046

  alb-sg:                               # D-022
    managed_by: terraform
    name: commerce-prod-sg-alb
    attached_to: [alb]
    ingress:
      - protocol: tcp
        port: 443
        source: sg:nlb-sg
    egress:
      - protocol: tcp
        port: 8080
        destination: app-sg

  app-sg:                               # D-005
    managed_by: terraform
    name: commerce-prod-sg-app
    attached_to: [admin, b2b, b2c]
    ingress:
      - protocol: tcp
        port: 8080
        source: sg:alb-sg
      - protocol: tcp
        port: 22
        source: sg:bastion-sg
    egress:
      - protocol: all
        destination: 0.0.0.0/0

  loki-sg:                              # D-009, D-038
    managed_by: terraform
    name: commerce-prod-sg-loki
    attached_to: [log]
    ingress:
      - protocol: tcp
        port: 3100                      # Loki
        source: sg:app-sg
      - protocol: tcp
        port: 22
        source: sg:bastion-sg
      - protocol: tcp
        port: 3000                      # Grafana
        source: sg:bastion-sg
    egress:
      - protocol: all
        destination: 0.0.0.0/0

  bastion-sg:                           # D-011
    managed_by: terraform
    name: commerce-prod-sg-bastion
    attached_to: [bastion]
    ingress:
      - protocol: tcp
        port: 22
        source: 119.192.127.156/32
    egress:
      - protocol: all
        destination: 0.0.0.0/0

  rds-sg:                               # D-011
    managed_by: terraform
    name: commerce-prod-sg-rds
    attached_to: [rds]
    ingress:
      - protocol: tcp
        port: 3306
        source: sg:app-sg
      - protocol: tcp
        port: 3306
        source: sg:bastion-sg

  redis-sg:                             # D-011
    managed_by: terraform
    name: commerce-prod-sg-redis
    attached_to: [redis]
    ingress:
      - protocol: tcp
        port: 6379
        source: sg:app-sg
      - protocol: tcp
        port: 6379
        source: sg:bastion-sg
```

## 4.3 Load Balancing

```yaml
NLB:
  nlb:
    managed_by: terraform
    name: commerce-prod-nlb-public
    load_balancer_type: network
    internal: false
    subnet_mapping:
      - subnet: public-nlb
        allocation_id: eip:nlb          # REQ-01 고정 Public IP
    security_groups: [nlb-sg]           # D-013. AWS 제약: NLB SG는 생성 시에만 연결 가능
    enable_cross_zone_load_balancing: false  # D-012

NLBListener:
  nlb-443:
    managed_by: terraform
    name: commerce-prod-listener-nlb-443   # Name 태그
    load_balancer: nlb
    port: 443
    protocol: tcp              
    default_action:
      type: forward
      target_group: nlb-tg-alb
  # 80 Listener는 생성하지 않는다     # D-001

NLBTargetGroup:
  nlb-tg-alb:
    managed_by: terraform
    name: commerce-prod-tg-nlb-alb
    target_type: alb
    protocol: tcp
    port: 443                           # AWS 제약: ALB Listener 포트와 일치
    vpc: main
    health_check:                       # D-029
      protocol: HTTPS
      path: /healthz
      matcher: "200"
    targets: []                         # ALB 등록은 수동 (D-035)

ALB:
  alb:
    managed_by: terraform
    name: commerce-prod-alb-internal
    load_balancer_type: application
    internal: true                      # Private Subnet 배치 (REQ-08)
    subnets: [private-alb-a, private-alb-c]
    security_groups: [alb-sg]
    # Listener는 Terraform으로 생성하지 않는다 (D-035)
```

### 4.3.1 수동 구성 명세 (참고용, Terraform 미생성)

```yaml
ALBListener:
  alb-443:
    managed_by: manual                  # D-035: ACM 인증서 발급 완료 후 생성
    port: 443
    protocol: HTTPS
    certificate: acm:imcommerce         # D-033
    ssl_policy: 정의하지 않음           # R1-19 기각 (D-028)
    default_action:
      type: forward                     # D-029
      target_group: 미확정(U-08)
  # 80 Listener는 생성하지 않는다     # D-001

ALBListenerRule:                        # D-042
  admin:
    managed_by: manual
    condition: host-header = admin.imcommerce.shop
    action: forward → alb-tg-admin
  b2b:
    managed_by: manual
    condition: host-header = b2b.imcommerce.shop
    action: forward → alb-tg-b2b
  b2c:
    managed_by: manual
    condition: host-header = b2c.imcommerce.shop
    action: forward → alb-tg-b2c

ALBTargetGroup:                         # D-042
  alb-tg-admin:
    managed_by: manual
    target_type: instance
    protocol: HTTP                      # D-026: ALB → EC2 구간 암호화 선택하지 않음
    port: 8080
    health_check:
      path: /healthz                    # architecture.md REQ-02
    targets: [admin]                    # 등록 주체 미확정(U-09)
  alb-tg-b2b:
    managed_by: manual
    target_type: instance
    protocol: HTTP
    port: 8080
    health_check:
      path: /healthz
    targets: [b2b]
  alb-tg-b2c:
    managed_by: manual
    target_type: instance
    protocol: HTTP
    port: 8080
    health_check:
      path: /healthz
    targets: [b2c]

NLBTargetRegistration:
  nlb-tg-alb:
    managed_by: manual                  # D-035
    target: alb
    port: 443
```

## 4.4 DNS · Certificate

```yaml
Route53Zone:
  imcommerce:
    managed_by: terraform               # D-032
    name: imcommerce.shop                # zone 이름 = 도메인
    tag_name: commerce-prod-zone-imcommerce
    type: public
Route53Record:                          # 수동 (D-032)
  admin:
    managed_by: manual
    name: admin.imcommerce.shop
    type: A (Alias)
    target: nlb
  b2b:
    managed_by: manual
    name: b2b.imcommerce.shop
    type: A (Alias)
    target: nlb
  b2c:
    managed_by: manual
    name: b2c.imcommerce.shop
    type: A (Alias)
    target: nlb

RegistrarNSDelegation:
  managed_by: manual                    # D-032

ACMCertificate:
  imcommerce:
    managed_by: terraform            # D-033: ACM에서 발급
    name: commerce-prod-acm-imcommerce   # Name 태그
    domain_name: imcommerce.shop
    subject_alternative_names:
      - "*.imcommerce.shop"
    validation_method: DNS
    validation_record: manual           # D-037
```

## 4.5 Compute

**EC2 OS 공통 정보**
```yaml
ami: 
      os: ubuntu-24.04
      architecture: x86_64
      selection_method: fixed_ami_id
      ami_id: ami-05b829d75c9f9183e
```

**Key Pair (기존 리소스 참조)**
```yaml
KeyPair:                                # U-14 결정: AWS에 수동으로 구성된 Key Pair를 이름으로만 참조
  managed_by: manual                    # Terraform은 생성하지 않음 (aws_key_pair 미사용)
  referenced_names:
    - commerce-prod-app-key             # admin, b2b, b2c
    - commerce-prod-log-key             # log
    - commerce-prod-bastion-key         # bastion
```

**EC2별 상세 설정**
```yaml
EC2:
  admin:
    count: 1
    name: commerce-prod-ec2-admin          # Name 태그
    subnet: private-app
    security_groups: [app-sg]
    instance_type: t3.medium
    imdsv2: required                    # D-024 (http_tokens = "required")
    associate_public_ip_address: false
    key_name: commerce-prod-app-key
    root_volume_size: 10
    ebs_encryption: true
    user_data: none
    software: [JDK 17, Grafana Alloy, CodeDeploy Agent(수동, D-020)]

  b2b:
    count: 1
    name: commerce-prod-ec2-b2b          # Name 태그
    subnet: private-app
    security_groups: [app-sg]
    instance_type: t3.medium
    imdsv2: required
    associate_public_ip_address: false
    key_name: commerce-prod-app-key
    root_volume_size: 10
    ebs_encryption: true
    user_data: none
    software: [JDK 17, Grafana Alloy, CodeDeploy Agent(수동, D-020)]

  b2c:
    count: 1
    name: commerce-prod-ec2-b2c          # Name 태그
    subnet: private-app
    security_groups: [app-sg]
    instance_type: t3.medium
    imdsv2: required
    associate_public_ip_address: false
    key_name: commerce-prod-app-key
    root_volume_size: 10
    ebs_encryption: true
    user_data: none
    software: [JDK 17, Grafana Alloy, CodeDeploy Agent(수동, D-020)]

  log:
    count: 1
    name: commerce-prod-ec2-log          # Name 태그
    subnet: private-app                 # D-009
    security_groups: [loki-sg]
    instance_type: t3.large
    imdsv2: required
    associate_public_ip_address: false
    key_name: commerce-prod-log-key
    root_volume_size: 20                # D-025 (root volume으로 구성, U-12 결정)
    ebs_encryption: true
    user_data: none
    software: [Grafana Loki, Grafana]
    grafana_admin_password: admin       # D-034 (R-004)

  bastion:
    count: 1
    name: commerce-prod-ec2-bastion          # Name 태그
    subnet: public-bastion
    security_groups: [bastion-sg]
    instance_type: t3.medium
    imdsv2: required
    public_ip: true
    key_name: commerce-prod-bastion-key
    root_volume_size: 10
    ebs_encryption: true
```

## 4.6 Database

```yaml
DBSubnetGroup:
  rds:
    managed_by: terraform
    name: commerce-prod-dbsubnet-rds
    subnets: [private-rds-a, private-rds-c]   # D-008, D-019

DBParameterGroup:
  mysql:
    managed_by: terraform
    name: commerce-prod-dbparam-mysql80
    family: mysql8.0                 
    parameters:
      - name: require_secure_transport
        value: "1"                       # D-026 RDS 연결 TLS 강제

RDS:
  mysql:
    managed_by: terraform
    identifier: commerce-prod-rds-mysql
    engine: mysql
    engine_version: "8.0"
    instance_class: db.t3.medium
    allocated_storage: 20
    storage_type: gp3
    multi_az: false
    availability_zone: ap-northeast-2a
    db_subnet_group: rds
    parameter_group: mysql
    vpc_security_group_ids: [rds-sg]
    port: 3306
    publicly_accessible: false           # REQ-03 외부 직접 접근 차단
    storage_encrypted: true              # D-026
    kms_key_id: null
    db_name: commerce
    username: dbadmin
    manage_master_user_password: true    # D-010
    master_user_secret_kms_key_id: null
    secret_rotation: 변경하지 않음        # D-036 (R-005)
    backup_retention_period: 0
    skip_final_snapshot: true
    deletion_protection: false
```

## 4.7 Cache

```yaml
ElastiCacheSubnetGroup:
  redis:
    managed_by: terraform
    name: commerce-prod-cachesubnet-redis
    subnets: [private-redis]

ElastiCache:
  redis:
    managed_by: terraform
    replication_group_id: commerce-prod-redis-main
    resource_type: aws_elasticache_replication_group
    description: Redis cache for commerce production
    engine: redis                        # context.md: Redis OSS 7
    engine_version: "7.1"
    node_type: cache.t4g.small
    num_nodes: 1
    subnet_group: redis
    security_group_ids: [redis-sg]
    port: 6379
    transit_encryption_enabled: true     # D-023
    transit_encryption_mode: required
    auth_token: 사용하지 않음             # D-023
    at_rest_encryption_enabled: true
```

## 4.8 CI/CD

```yaml
S3:
  artifact:
    managed_by: terraform
    purpose: CodeDeploy 배포 아티팩트 저장   # architecture.md REQ-05
    bucket_name: commerce-prod-codedeploy-artifacts
    versioning: Enabled
    encryption: AES256
    public_access_block:
      block_public_acls: false
      ignore_public_acls: false
      block_public_policy: false
      restrict_public_buckets: false
    force_destroy: true

CodeDeployApplication:
  managed_by: terraform                  # D-021
  compute_platform: Server
  count: 1
  name: commerce-prod-codedeploy-cd

CodeDeployDeploymentGroup:
  managed_by: manual                     # D-021
```


# 5. 연결 관계 및 수동 작업

## 5.1 트래픽 경로

| 경로 | 프로토콜/포트 | 허용 근거 |
|---|---|---|
| 사용자 → NLB (EIP) | TCP 443 | nlb-sg ingress (D-022) |
| NLB → ALB | TCP 443 | alb-sg ingress from nlb-sg (D-022) |
| ALB → admin, b2b, b2c | HTTP 8080 | app-sg ingress from alb-sg (D-005) |
| admin, b2b, b2c → RDS | TCP 3306 (TLS) | rds-sg ingress from app-sg (D-011, D-026) |
| admin, b2b, b2c → Redis | TCP 6379 (TLS) | redis-sg ingress from app-sg (D-011, D-023) |
| admin, b2b, b2c → log (Loki) | TCP 3100 | loki-sg ingress from app-sg (D-009) |
| 관리자 → Bastion | TCP 22 | bastion-sg ingress from 119.192.127.156/32 (D-011) |
| Bastion → admin, b2b, b2c, log | TCP 22 | app-sg, loki-sg ingress from bastion-sg (D-005, D-009) |
| Bastion → log (Grafana) | TCP 3000 | loki-sg ingress from bastion-sg (D-038) |
| Bastion → RDS, Redis | TCP 3306, 6379 | rds-sg, redis-sg ingress from bastion-sg (D-011) |
| private-app → 인터넷 | all | NAT Gateway (D-004), app-sg·loki-sg egress 전체 허용 (D-046) |

## 5.2 수동 작업 목록
아래 작업은 Terraform apply 이후 엔지니어가 수동으로 수행한다. 작업 순서는 결정되지 않았으며, 확정된 의존 관계만 표시한다.

| 작업 | 근거 | 선행 조건 |
|---|---|---|
| registrar NS 위임 | D-032 | Route 53 Hosted Zone 생성 |
| ACM DNS 검증 CNAME 등록 | D-037 | ACM 인증서 생성 (Terraform) |
| ALB Target Group 3개 생성 | D-042 | - |
| EC2를 ALB Target Group에 등록 | U-09 | ALB Target Group 생성 |
| ALB HTTPS(443) Listener 생성 | D-035 | ACM 인증서 발급 완료 |
| ALB Listener Rule 3개 생성 | D-042 | ALB Listener 생성 |
| NLB Target Group에 ALB 등록 | D-035 | ALB Listener 생성 (AWS 제약: TG 포트와 일치하는 Listener 필요) |
| Route 53 Alias 레코드 3개 등록 | D-032 | - |
| EC2 Instance Profile, CodeDeploy Service Role, GitHub Actions 인증 구성 | D-017 | EC2, CodeDeploy, S3 배포 |
| CodeDeploy Deployment Group 구성 | D-021 | CodeDeploy Service Role |
| CodeDeploy Agent 설치 | D-020 | - |
| JDK 17, Alloy, Loki, Grafana 설치 | §4.5 (`user_data: none`) | EC2 생성 |
| Alloy 서버별 정적 label 설정 | D-018 | Alloy 설치 |
| 앱 설정에 RDS master password 고정값 설정 | D-036 | RDS 생성 |


# 6. 미확정 사항

§4의 YAML 스펙(v1.0) 기준으로 정리했다. 미해소 항목이 남아 있는 동안 해당 리소스의 Terraform 구현을 시작하지 않는다.

## 6.1 미해소 항목 (Terraform 생성 리소스)

미해소 항목 없음.

## 6.2 아키텍처와 불일치하는 항목

불일치 항목 없음. X-01(SG egress와 D-041 불일치)은 명세 승인에 따라 D-046으로 architecture.md v1.2에 반영되어 해소되었다.

## 6.3 수동 구성 관련 미확정 항목 (Terraform 범위 외)

| ID | 대상 | 미확정 내용 | 관련 리뷰/결정 |
|---|---|---|---|
| U-08 | ALB | HTTPS Listener default Forward 대상 Target Group. NLB 헬스 체크는 이 대상 서비스 상태만 반영함 | R2-03, R2-12, D-029 |
| U-09 | ALB | EC2를 ALB Target Group에 등록하는 작업의 담당 주체 | R2-03, D-042 |

## 6.4 해소된 항목

| ID | 반영 위치 | 반영 값 |
|---|---|---|
| U-01 | §2 | `unspecified_arguments`: 선택 인자 생략 시 Provider/AWS 기본값, 보안·아키텍처 영향 값은 명시 |
| U-02 | §1.2, §4 | 명명 규칙에 따라 Terraform 리소스별 `name` 작성(AI 작성, 엔지니어 지시). 이름 인자가 없는 리소스는 `Name` 태그로 사용 |
| U-03 | §2 | Terraform 1.17.2, AWS Provider 6.71.0 |
| U-04 | §4.1 | local 경로만 있는 `private-local` Route Table을 명시적으로 생성하여 ALB·Redis·RDS Subnet 5개에 연결 |
| U-11 | §4.5 | Ubuntu 24.04, x86_64, AMI ID 고정 `ami-05b829d75c9f9183e` |
| U-12 | §4.5 | 로그 서버 20GiB는 root volume |
| U-14 | §4.5 | Key Pair는 AWS에 수동 구성된 기존 리소스를 이름으로만 참조 (`commerce-prod-app-key`, `commerce-prod-log-key`, `commerce-prod-bastion-key`) |
| U-05 | §4.3 | NLB Listener·Target Group 프로토콜 TCP |
| U-06 | §4.3 | `preserve_client_ip` 미지정. AWS 문서상 `alb` 유형 TG는 속성 변경 불가이며 client IP가 항상 보존되고, NLB SG 참조는 client IP 보존 시에도 동작함 |
| U-07 | §4.4 | ACM 인증서 Terraform 생성, `imcommerce.shop` + `*.imcommerce.shop`, DNS 검증(CNAME 수동) |
| U-10 | §4.5 | admin·b2b·b2c·bastion t3.medium, log t3.large |
| U-12 (앱·Bastion) | §4.5 | admin·b2b·b2c·bastion root volume 10GiB |
| U-13 | §4.5 | 전 EC2 EBS 암호화 |
| U-15 | §4.1, §4.5 | Bastion Public IP 자동 할당(`map_public_ip_on_launch: true`) |
| U-16 | §4.5 | `user_data` 미사용(소프트웨어 수동 설치) |
| U-17 | §4.6 | MySQL 8.0, Parameter Group family `mysql8.0` |
| U-18 | §4.6 | db.t3.medium, 20GiB, gp3 |
| U-19 | §4.6 | Single-AZ, ap-northeast-2a |
| U-20 | §4.6 | db_name `commerce`, username `dbadmin` |
| U-21 | §4.6 | AWS 관리형 KMS key (`null`) |
| U-22 | §4.6 | backup retention 0, 최종 스냅샷 생략, 삭제 보호 해제 |
| U-23 | §4.7 | `aws_elasticache_replication_group`, 7.1, cache.t4g.small, 노드 1개 |
| U-24 | §4.7 | `transit_encryption_mode: required`, 저장 암호화 적용 |
| U-25 | §4.8 | bucket `commerce-prod-codedeploy-artifacts`, versioning, AES256, Public Access Block 4개 모두 false, `force_destroy: true` |
| U-26 | §4.8 | Application 1개, `commerce-prod-codedeploy-cd` |
| U-27 | §4.7 | ElastiCache `description`: `Redis cache for commerce production` (Provider 필수 인자) |

## 6.5 Terraform 구현 외 확인 사항
- R2-09: 앱의 Redis SSL 설정(`spring.data.redis.ssl.enabled=true` 등)이 필요한지 앱 측과 확인해야 한다.
- R2-12, R2-13, R2-17: Terraform 설정값에는 영향이 없지만 아직 결정되지 않았다.
