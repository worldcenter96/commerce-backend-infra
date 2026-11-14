# AI Decision Log

| 항목 | 값 |
|---|---|
| 상태 | Approved |
| 버전 | 1.0 |
| 날짜 | 2026-11-14 |

엔지니어가 확인한 의사결정 및 위험 수용 이력을 기록한다.


# 1. 결정 이력

| ID | 날짜 | 관련 요구사항 | 결정 내용 | 배경 | 기준 문서 |
|---|---|---|---|---|---|
| D-001 | 2026-11-13 | REQ-01 | NLB에 80 Listener를 두지 않고, NLB에서 ALB로는 443만 전달하여 HTTP 요청을 차단한다. | architecture.md에 HTTP 차단 방식이 정의되어 있지 않음 | context.md v0.1, architecture.md v0.1 |
| D-002 | 2026-11-13 | REQ-06 | ~~서비스별 로그 구분 조회는 애플리케이션 코드에서 구분하여 필터링하므로 인프라 구축 범위에서 제외한다.~~ (D-018로 대체) | architecture.md에 서비스별 로그 구분 방식이 정의되어 있지 않음 | context.md v0.1, architecture.md v0.1 |
| D-003 | 2026-11-13 | REQ-07 | 민감 정보 관리 방식은 인프라 배포 완료 후 결정하며 현재 논의하지 않는다. | architecture.md에 민감 정보 저장 및 주입 방식이 정의되어 있지 않음 | context.md v0.1, architecture.md v0.1 |
| D-004 | 2026-11-13 | REQ-08 | "외부와 통신"은 Private Subnet의 서버가 먼저 연결을 시작하는 NAT Gateway 경유 outbound 통신으로 한정한다. | context.md 표현의 해석 확정 필요 | context.md v0.1, architecture.md v0.1 |
| D-005 | 2026-11-13 | REQ-07 | 애플리케이션 EC2 3대는 1개의 Security Group을 공유하며, 인바운드는 ALB Security Group으로부터의 8080, Bastion Security Group으로부터의 22만 허용한다. | 초안(0.0.0.0/0:8080)은 VPC 내부 모든 리소스의 8080 접근을 허용하여 "필요한 통신만 허용"과 충돌하므로 source를 SG 참조로 제한함 | context.md v0.1, architecture.md v0.1 |
| D-006 | 2026-11-13 | REQ-07 | ~~RDS master password는 Terraform 생성 시 임시 값을 사용하고 추후 수정한다.~~ (D-010으로 대체) | D-003에 따라 민감 정보 관리 방식이 미정 | context.md v0.1, architecture.md v0.1 |
| D-007 | 2026-11-13 | REQ-06, REQ-08 | 아키텍처 다이어그램(architecture-v0.1.png)에 로그 모니터링 EC2가 없는 불일치에 대해 현재 다이어그램과 본문을 모두 수정하지 않는다. | architecture.md 본문과 다이어그램 간 불일치 | architecture.md v0.1 |
| D-008 | 2026-11-13 | REQ-03 | RDS DB Subnet Group의 2개 AZ 조건을 충족하도록 다른 AZ에 RDS용 Private Subnet을 추가로 확보한다. | R1-01 (수용) | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-009 | 2026-11-13 | REQ-06, REQ-07 | 로그 모니터링 EC2는 애플리케이션 서버와 같은 Private Subnet에 배치한다. Loki SG를 정의하여 인바운드는 App SG로부터의 3100, Bastion SG로부터의 22만 허용한다. Grafana는 Bastion을 경유한 접근(예: SSH 터널)만 허용한다. | R1-02 (수용) | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-010 | 2026-11-13 | REQ-07, REQ-03 | RDS master password는 manage_master_user_password를 사용하여 Secrets Manager에서 관리한다. D-006을 대체한다. | R1-03 (수정 수용). 애플리케이션 접속 정보 주입 방식은 미결정 | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-011 | 2026-11-13 | REQ-03, REQ-04, REQ-07 | Bastion SG 인바운드는 119.192.127.156/32로부터의 22만 허용한다. RDS SG(3306)와 Redis SG(6379)는 App SG와 Bastion SG로부터의 인바운드만 허용한다. | R1-04 (수용) | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-012 | 2026-11-13 | REQ-01 | NLB Subnet의 AZ를 ALB Subnet의 AZ 중 하나와 일치시키고, NLB Cross-Zone Load Balancing은 사용하지 않는다. | R1-05 (부분 수용). 헬스 체크, NLB SG, ALB SG 출발지, Client IP는 미결정 | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-013 | 2026-11-13 | REQ-01, REQ-07 | NLB에 Security Group을 연결한다. | R1-05 (부분 수용). 헬스 체크, ALB SG 출발지, Client IP는 미결정 | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-014 | 2026-11-13 | REQ-05, REQ-02 | appspec ValidateService 단계에서 localhost:8080/healthz를 재시도하며 확인하고, 실패하면 non-zero로 종료한다. | R1-06 (수용) | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-015 | 2026-11-13 | REQ-01, REQ-07 | Admin 서비스는 출발지 제한 없이 기존대로 외부에 공개한다. | R1-07 (위험 수용). R-003 참조 | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-016 | 2026-11-13 | REQ-02 | 세 서비스에 /healthz가 구현되어 있음을 확인했다. | R1-08 (해소). 장애 알림 경로는 미결정 | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-017 | 2026-11-13 | REQ-05, REQ-07 | EC2, CodeDeploy, S3 인프라 배포 후 EC2 Instance Profile, CodeDeploy Service Role, GitHub Actions 인증 방식을 수동으로 구성한다. | R1-09 (수정 수용) | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-018 | 2026-11-13 | REQ-06 | 서비스별 로그 구분은 각 애플리케이션 서버의 Alloy에 서버별 정적 label(예: service=admin)을 부여하여 수행하며, 설정은 수동으로 진행한다. D-002를 대체한다. | R1-10 (수정 수용) | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-019 | 2026-11-13 | REQ-03, REQ-08 | 로그 서버를 App Subnet에 함께 두고(D-009), 192.168.0.96/27을 RDS용 두 번째 Private Subnet으로 사용한다. | R1-11 (수용), R1-01 보완 | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-020 | 2026-11-13 | REQ-05 | CodeDeploy Agent는 인프라 구축 완료 후 애플리케이션 서버에 수동으로 설치한다. | R1-12 (부분 수용). Deployment Group 구성 단위, EC2 식별 기준, Ubuntu 24.04 지원 여부는 미결정 | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-021 | 2026-11-13 | REQ-05 | Terraform은 CodeDeploy Application까지만 생성하며, Deployment Group은 수동으로 구성한다. | R1-09 후속. Deployment Group 생성에 CodeDeploy Service Role이 필요하나 Service Role은 인프라 배포 후 수동 구성(D-017) | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-022 | 2026-11-13 | REQ-01, REQ-07 | NLB SG 인바운드는 0.0.0.0/0으로부터의 443을 허용하고, ALB SG 인바운드는 NLB SG로부터의 443만 허용한다. | R1-05 (부분 수용). 헬스 체크(ALB default action), Client IP는 미결정 | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-023 | 2026-11-13 | REQ-04, REQ-07 | ElastiCache Redis는 전송 구간 암호화(TLS)를 적용하며, AUTH는 적용하지 않는다. | R1-13 (수정 수용) | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-024 | 2026-11-13 | REQ-07 | 모든 EC2에 metadata_options.http_tokens = "required"를 적용하여 IMDSv2를 강제한다. | R1-14 (수용) | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-025 | 2026-11-13 | REQ-06 | 로그 모니터링 서버의 EBS 크기는 20GiB로 한다. Loki retention은 현재 논의 범위에서 제외한다. | R1-16 (부분 수용) | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-026 | 2026-11-13 | REQ-03, REQ-07 | RDS 저장 암호화를 적용하고, RDS 연결에 TLS를 강제한다. ALB → EC2 구간 암호화는 선택하지 않았다. | R1-18 (부분 수용) | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-027 | 2026-11-13 | REQ-01 | ~~ACM에서 인증서를 생성하지 않으며, 인프라 배포 완료 후 인증서를 ACM에 업로드한다.~~ (D-033으로 대체) | R1-22 (수정 수용). Route 53 Hosted Zone 및 NS 위임 상태는 미확인 | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-028 | 2026-11-13 | - | R1-15(프로세스 관리), R1-17(앱 SG 공유), R1-19(ALB TLS 정책, 관리 엔드포인트), R1-20(Egress 통제), R1-21(in-place 배포 다운타임), R1-23(다이어그램 표현 오류, 문서 버전 불일치)을 기각한다. | R1 리뷰 (기각) | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-029 | 2026-11-13 | REQ-01 | ALB HTTPS Listener의 default action은 Forward로 한다. NLB의 ALB 대상 Target Group 헬스 체크는 protocol HTTPS, path /healthz, Success Code 200으로 한다. Client IP 보존은 요구하지 않는다. | R1-05 (부분 수용). 헬스 체크 path는 초기 결정 `/`에서 `/healthz`로 변경(동일 일자). Forward 대상 Target Group은 미결정 | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-030 | 2026-11-13 | REQ-02 | 헬스 체크 결과에 대한 장애 알림은 구성하지 않는다. | R1-08 (기각) | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-031 | 2026-11-13 | REQ-05 | CodeDeploy 대상 EC2 식별 기준 및 CodeDeploy Agent의 Ubuntu 24.04 지원 여부는 인프라 설계에서 정의하지 않는다. | R1-12 잔여 항목 (기각). Deployment Group(D-021)과 Agent 설치(D-020)는 수동 | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-032 | 2026-11-13 | REQ-01 | Route 53은 Terraform으로 imcommerce.shop Public Hosted Zone만 생성하며, 그 외 작업(서비스 도메인 Alias 레코드, registrar NS 위임)은 수동으로 진행한다. | R1-22 (수정 수용) | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-033 | 2026-11-13 | REQ-01 | ALB HTTPS Listener의 TLS 인증서는 ACM에서 발급한다. D-027을 대체한다. | 외부 인증서를 배포 후 업로드하면 ALB 443 Listener를 생성할 수 없는 순서 문제. 인증서 범위 및 DNS 검증 레코드 처리 방식은 미결정 | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-034 | 2026-11-13 | REQ-06, REQ-07 | Grafana 초기 관리자 비밀번호는 기본값(admin)을 유지한다. | R1-02 잔여 항목. R-004 참조 | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-035 | 2026-11-13 | REQ-01 | ALB HTTPS(443) Listener 생성과 NLB Target Group에 대한 ALB 등록은 ACM 인증서 발급 완료 후 수동으로 진행한다. | D-033 후속. ACM DNS 검증에 필요한 registrar NS 위임(D-032)과 검증 CNAME 등록(D-037)이 수동이므로 Terraform 실행 중 인증서 발급을 기다릴 수 없음. (R2-05에 따라 배경 정정: 기존 문구는 검증 CNAME 수동 처리를 D-032에 포함된 것으로 잘못 기재함) | context.md v0.2, architecture.md v0.2, R1 리뷰 |
| D-036 | 2026-11-13 | REQ-03, REQ-07 | 애플리케이션은 RDS master password를 앱 설정에 고정값으로 넣어 사용한다. Secrets Manager rotation 대응(주기 조정, 런타임 조회, 앱 전용 DB 계정)은 적용하지 않는다. | R2-01 (위험 수용). 인프라를 2일 후 삭제할 예정이므로 rotation 전에 DB가 삭제됨. R-005 참조 | context.md v0.2, architecture.md v0.2, R2 리뷰 |
| D-037 | 2026-11-13 | REQ-01 | ACM DNS 검증 CNAME은 엔지니어가 수동으로 등록한다. | R2-05 (부분 수용). ACM 인증서 요청 주체와 인증서 범위는 미결정 | context.md v0.2, architecture.md v0.2, R2 리뷰 |
| D-038 | 2026-11-13 | REQ-06, REQ-07 | Loki SG 인바운드에 Bastion SG로부터의 3000(Grafana)을 추가로 허용한다. | R2-07 (수정 수용). D-009의 Loki SG 인바운드를 확장 | context.md v0.2, architecture.md v0.2, R2 리뷰 |
| D-039 | 2026-11-13 | - | R2-04(수동 IAM 최소 권한 기준), R2-08(Terraform과 수동 작업 간 drift, destroy 실패)을 기각한다. | R2 리뷰 (기각) | context.md v0.2, architecture.md v0.2, R2 리뷰 |
| D-040 | 2026-11-13 | - | context.md와 architecture.md를 승인하고 각각 v1.0으로 버전업한다. architecture.md의 모든 채택 인프라 확정 여부를 "결정"으로 변경한다. | 엔지니어 승인. 승인 시점 R2 미결 항목: R2-02, R2-03, R2-05(인증서 요청 주체·범위), R2-06(AZ 값), R2-09~R2-17 | context.md v1.0, architecture.md v1.0, R2 리뷰 |
| D-041 | 2026-11-13 | REQ-07, REQ-08 | ~~모든 Security Group의 egress는 0.0.0.0/0 전체 허용으로 한다.~~ (D-046으로 대체) | R2-02 (수용). Terraform aws_security_group은 기본 allow-all egress를 제거하므로 명시 필요 | context.md v1.0, architecture.md v1.0, R2 리뷰 |
| D-042 | 2026-11-13 | REQ-01, REQ-02 | ALB Host 기반 Listener Rule과 서비스별 Target Group은 수동으로 생성한다. | R2-03 (수용). 443 Listener 수동 생성(D-035)과 함께 진행. default Forward 대상 Target Group은 미결정 | context.md v1.0, architecture.md v1.0, R2 리뷰 |
| D-043 | 2026-11-13 | REQ-01, REQ-03, REQ-08 | Subnet은 가능한 한 모두 ap-northeast-2a에 배치하고, 서로 다른 AZ가 필요한 RDS Subnet(192.168.0.192/27, 192.168.0.96/27)을 위해 ap-northeast-2c를 추가로 사용한다. | R2-06 (수정 수용). Subnet별 AZ 매핑 표는 D-044에서 확정 | context.md v1.0, architecture.md v1.0, R2 리뷰 |
| D-044 | 2026-11-13 | REQ-01, REQ-03, REQ-08 | Subnet별 AZ를 다음과 같이 확정한다. 2a: .0/27(Bastion, NAT), .128/27(NLB), .64/27(ALB), .32/27(App, 로그 서버), .160/27(Redis), .192/27(RDS). 2c: .224/27(ALB), .96/27(RDS). | D-043 후속. ALB는 최소 2개 AZ의 Subnet이 필요하므로 ALB Subnet 하나도 2c에 배치. App·NLB Subnet AZ(2a)는 ALB Subnet AZ에 포함(D-012) | context.md v1.0, architecture.md v1.1, R2 리뷰 |
| D-045 | 2026-11-14 | - | infrastructure-spec.md를 승인하고 v1.0으로 확정한다. 승인된 명세에 맞춰 architecture.md를 v1.2로 갱신한다(D-046 ~ D-052). | 엔지니어 승인. 수동 구성 관련 미확정 U-08(default Forward 대상), U-09(ALB TG 등록 주체)는 남아 있음 | context.md v1.0, architecture.md v1.2, infrastructure-spec.md v1.0 |
| D-046 | 2026-11-14 | REQ-07 | SG egress: NLB SG는 ALB SG로의 443만, ALB SG는 App SG로의 8080만 허용한다. App·Loki·Bastion SG는 0.0.0.0/0 전체 허용, RDS·Redis SG는 egress 규칙을 두지 않는다. D-041을 대체한다. | infrastructure-spec.md 승인(X-01 해소) | context.md v1.0, architecture.md v1.2, infrastructure-spec.md v1.0 |
| D-047 | 2026-11-14 | REQ-01 | ACM 인증서는 Terraform으로 요청하며, 범위는 imcommerce.shop과 *.imcommerce.shop으로 한다. NLB Listener와 ALB 대상 Target Group은 TCP 443으로 구성한다. | R2-05 잔여, R2-15. infrastructure-spec.md 승인 | context.md v1.0, architecture.md v1.2, infrastructure-spec.md v1.0 |
| D-048 | 2026-11-14 | REQ-08 | NAT 경로는 App Subnet에만 두고, ALB·Redis·RDS Subnet은 local 경로만 있는 별도 Private Route Table에 연결한다. | R2-16 (Route Table). infrastructure-spec.md 승인 | context.md v1.0, architecture.md v1.2, infrastructure-spec.md v1.0 |
| D-049 | 2026-11-14 | REQ-07 | 모든 EC2 EBS에 저장 암호화를 적용한다. Key Pair는 AWS에 수동 생성된 기존 Key Pair를 이름으로 참조한다(앱 서버 3대 공용 1개, 로그 서버 1개, Bastion 1개). Bastion은 Public IP 자동 할당을 사용한다. | R2-10, R2-14 (EBS). infrastructure-spec.md 승인 | context.md v1.0, architecture.md v1.2, infrastructure-spec.md v1.0 |
| D-050 | 2026-11-14 | REQ-02, REQ-06 | EC2에 user_data를 사용하지 않으며, JDK 17, Grafana Alloy, Loki, Grafana는 수동으로 설치한다. 로그 서버 20GiB는 root volume으로 구성한다. | R2-10 (설치 주체). infrastructure-spec.md 승인 | context.md v1.0, architecture.md v1.2, infrastructure-spec.md v1.0 |
| D-051 | 2026-11-14 | REQ-03, REQ-04 | RDS는 Single-AZ(ap-northeast-2a)로 구성하고 자동 백업과 최종 스냅샷을 사용하지 않는다. ElastiCache는 노드 1개의 replication group으로 구성하고 저장 암호화를 적용한다. | R2-09 (리소스 유형), R2-14 (Redis). infrastructure-spec.md 승인 | context.md v1.0, architecture.md v1.2, infrastructure-spec.md v1.0 |
| D-052 | 2026-11-14 | REQ-05 | CodeDeploy Application은 3개 서비스 공용 1개로 한다. 배포 아티팩트 S3 버킷은 versioning과 SSE-S3를 적용하고, Public Access Block은 적용하지 않는다. | infrastructure-spec.md 승인 | context.md v1.0, architecture.md v1.2, infrastructure-spec.md v1.0 |
| D-053 | 2026-11-14 | - | images/architecture-v1.0.png를 확정 아키텍처 다이어그램으로 승인하고 architecture.md(v1.3) §2.1에 반영한다. 다이어그램은 서비스 트래픽(Public 인바운드: 빨간선, Private 인바운드: 파란선)만 표시하며, ap-northeast-2c Subnet(.224/27, .96/27)은 표시하지 않는다. | 엔지니어 승인. architecture-v0.1.png를 대체. 2c Subnet은 문서 기준으로 계속 구성(D-044) | context.md v1.0, architecture.md v1.3, infrastructure-spec.md v1.0 |


# 2. 수용한 위험

| ID | 관련 결정 | 위험 | 비고 |
|---|---|---|---|
| R-001 | D-006 | 임시 password가 Terraform local state 파일에 평문으로 저장된다. | state 및 `*.tfvars` 파일은 Git에서 제외한다 (CLAUDE.md §6). D-010으로 해소 |
| R-002 | D-006 | 추후 password를 Terraform 외부에서 변경하면 drift가 발생하고, 다음 apply 시 tfvars 값으로 되돌려질 수 있다. | 수정 방식 결정 시 함께 검토. D-010으로 해소 |
| R-003 | D-015 | Admin 서비스가 인터넷 전체에 공개되어 brute-force, credential stuffing, 스캐닝의 대상이 될 수 있다. | R1-07 |
| R-004 | D-034 | Grafana 관리자 계정이 기본 비밀번호(admin)로 유지되어, Bastion 또는 VPC 내부에 접근 가능한 주체가 로그 열람 및 Grafana 설정 변경을 할 수 있다. | 접근 경로는 Bastion 경유로 제한됨(D-009, D-038) |
| R-005 | D-036 | 인프라 운영 기간이 Secrets Manager 자동 rotation 주기(기본 7일로 알려져 있으나 미검증)를 넘기면, rotation 이후 앱 설정의 고정 password가 무효가 되어 세 서비스의 DB 연결이 동시에 실패한다. 또한 앱 3대가 master 계정을 공유한다. | R2-01. 인프라 2일 후 삭제 예정을 전제로 수용 |
