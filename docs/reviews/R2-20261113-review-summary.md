# R2 아키텍처 리뷰 결과

| 항목 | 값 |
|---|---|
| 라운드 | R2 |
| 리뷰 일자 | 2026-11-13 |
| 리뷰 대상 | docs/context.md **v0.2** (2026-11-12), docs/architecture.md **v0.2** (2026-11-13, R1 결정 반영본·버전 미갱신), docs/ai-decision.md **v0.1** (D-001~D-035, R-001~R-004), images/architecture-v0.1.png |
| 리뷰어 | aws-pm-reviewer (PM), security-reviewer (SEC), sre-reviewer (SRE) |
| 이전 라운드 | docs/reviews/R1-20261113-review-summary.md |
| 상태 | 엔지니어 검토 대기 |

> 이 리뷰 결과는 AI의 제안이며 확정된 설계가 아니다. 엔지니어는 각 발견 사항을 수용, 수정, 거절, 보류, 위험 수용 중 하나로 결정하고, 그 결정을 docs/ai-decision.md에 기록한다.


# 1. 리뷰 수행 방식

- **서브에이전트 정의 대체 실행**
  - R1과 같은 방식으로 실행했다. `.claude/agents/`의 정의 파일 중 `security-reviewer.md`와 `sre-reviewer.md`는 비어 있고(0 byte), `aws-pm-reviewer.md`는 파일이 없다.
  - 그래서 docs/reviews/CLAUDE.md §2의 역할 정의를 프롬프트로 사용해 general-purpose 에이전트 3개를 독립 실행했다.
- **리뷰 대상**
  - 엔지니어 요청에 따라 R1 대상(context.md, architecture.md, 다이어그램)에 docs/ai-decision.md를 추가했다.
  - 리뷰어는 R1 리뷰 결과 파일과 다른 리뷰어의 결과를 참고하지 않았다.
- **재제기 제한**
  - 엔지니어가 이미 기각, 위험 수용, 범위 제외로 결정한 항목은 다시 제기하지 않도록 지시했다.
  - 예외는 두 가지다. 해당 결정이 다른 결정이나 요구사항과 모순되는 경우, 또는 구현이나 서비스 실행을 불가능하게 만드는 경우다.
  - 예외로 제기된 항목에는 관련 결정 ID를 표시했다.
- **중점 검토 항목**
  - 결정 간 모순과 의존·순서 문제
  - 결정이 architecture.md에 반영되었는지
  - 결정 때문에 새로 생긴 문제
  - Terraform 범위와 수동 작업 경계가 실제로 성립하는지
- **검증 상태 기준**
  - 문서 내용 대조 결과는 통합 과정에서 원본 파일로 확인했다.
  - AWS와 Terraform 동작에 대한 "확인된 사실"은 리뷰어가 분류한 것이다. 이번 라운드에서 공식 문서와 별도로 대조하지 않았다.
- **중복 통합**
  - 중복 발견 사항은 하나로 합쳤다.
  - 리뷰어 간 심각도가 다르면 가장 높은 값을 채택하고, 의견 차이는 별도로 기록했다.


# 2. 요약

| 심각도 | 건수 |
|---|---|
| Critical | 0 |
| High | 4 |
| Medium | 8 |
| Low | 5 |
| 합계 | 17 |

| ID | 심각도 | 제목 | 리뷰어 | 관련 결정 | 검증 상태 |
|---|---|---|---|---|---|
| R2-01 | High | RDS managed secret 자동 rotation과 앱 자격증명 주입 미결정의 충돌 | PM, SEC, SRE | D-003, D-010, D-017 | 확인된 사실 / 추론 |
| R2-02 | High | SG egress 미정의 (Terraform이 기본 allow-all egress를 제거함) | PM, SRE | D-005, D-009, D-011, D-022, D-028 | 확인된 사실 |
| R2-03 | High | ALB Listener Rule, Target Group 담당 주체와 default Forward 대상 미정의 | PM, SRE, SEC | D-029, D-035, D-015 | 확인된 사실 / 추론 |
| R2-04 | High | 수동 IAM의 최소 권한 기준 미정의 | SEC | D-017, D-021 | 확인된 사실 / 추론 |
| R2-05 | Medium | ACM 요청·DNS 검증 담당 주체, 인증서 범위 미정 및 결정 간 기술 불일치 | PM, SRE | D-032, D-033, D-035 | 확인된 사실 |
| R2-06 | Medium | Subnet별 AZ 배치 미정의 | PM | D-008, D-012, D-019 | 확인된 사실 |
| R2-07 | Medium | Grafana SSH 터널 방식과 Loki SG(3000 미허용)의 정합성 | SRE, PM, SEC | D-009 | 확인된 사실 / 추론 |
| R2-08 | Medium | Terraform과 수동 작업 간 drift, 재생성 시 수동 작업 소실, destroy 실패 | SRE, PM | D-017, D-018, D-020, D-021, D-031, D-032, D-035 | 확인된 사실 / 추가 검증 필요 |
| R2-09 | Medium | RDS·Redis TLS 강제에 필요한 앱 설정과 리소스 구성 조건 | PM, SRE, SEC | D-023, D-026 | 확인된 사실 / 추가 검증 필요 |
| R2-10 | Medium | EC2 소프트웨어 설치 주체, Bastion Key Pair, Public IP 미정의 | PM, SEC, SRE | D-018, D-020, D-011 | 확인된 사실 / 추론 |
| R2-11 | Medium | NLB SG 참조와 ALB-type TG의 Client IP 처리 조합 미확인 | SRE | D-013, D-022, D-029 | 추가 검증 필요 |
| R2-12 | Medium | NLB → ALB 헬스 체크가 default 대상 서비스 하나의 상태에 묶임 | PM, SRE | D-029 | 확인된 사실 / 추론 |
| R2-13 | Low | Loki 3100이 인증 없이 읽기·쓰기 API를 노출함 | SEC | D-009, D-018 | 확인된 사실 / 추론 |
| R2-14 | Low | Redis와 로그 서버 EBS의 저장 암호화 미정 | SEC | D-023, D-025, D-026 | 추가 검증 필요 |
| R2-15 | Low | NLB Listener와 Target Group 프로토콜(TCP) 미명시 | PM | D-001 | 확인된 사실 |
| R2-16 | Low | architecture.md 확정 여부와 본문 반영 누락 | PM, SRE, SEC | D-001~D-035 | 확인된 사실 |
| R2-17 | Low | CodeDeploy Agent의 Ubuntu 24.04 지원, IMDSv2 호환, 수동 설치 순서 | PM, SRE | D-020, D-024, D-031 | 추가 검증 필요 |


# 3. 발견 사항 상세

## R2-01. RDS managed secret 자동 rotation과 앱 자격증명 주입 미결정의 충돌
- **리뷰어**: PM (High), SEC (High), SRE (High)
- **심각도**: High
- **관련 요구사항**: REQ-03, REQ-07, REQ-02
- **관련 결정**: D-003 (민감 정보 관리 방식은 배포 후 결정), D-010 (manage_master_user_password), D-017 (Instance Profile 권한 범위), R-001·R-002 (해소 처리됨)
- **문제**
  - D-010에 따라 master password는 Secrets Manager가 관리한다.
  - 그런데 애플리케이션이 이 자격증명을 받는 방식은 정해지지 않았다(D-003).
  - D-017의 Instance Profile 범위에는 S3 읽기와 CodeDeploy Agent만 있고 `secretsmanager:GetSecretValue`가 없다.
  - 애플리케이션 전용 DB 계정도 정의되어 있지 않다.
- **근거**
  - 사실: RDS managed master user secret은 기본적으로 자동 rotation이 켜져 있다. 기본 주기는 7일이며, 최신 기본값은 재확인을 권장한다.
  - 사실: `manage_master_user_password`를 쓰면 password가 state에 저장되지 않으므로 R-001 해소는 타당하다.
  - 추론: 런타임에 secret을 조회할 경로가 없으므로, 운영자가 master password를 앱 설정에 고정값으로 넣을 가능성이 높다. 그러면 rotation 이후 DB 연결이 실패한다.
- **영향**
  - 배포 후 약 1주 안에 세 서비스가 동시에 DB 연결 장애를 겪을 수 있다. 장애 알림이 없으므로(D-030) 발견이 늦어진다.
  - 이를 피하려고 rotation을 끄거나 password를 저장소에 넣게 되면 REQ-07(Git 미노출)과 충돌한다.
  - 앱 3대가 모두 master 권한으로 접속하므로, 앱 서버 1대가 침해되면 DB 전체가 노출된다.
- **권장 조치**: D-003의 범위 결정 자체는 다시 열지 않는다. 다만 아래 사항은 결정이 필요하다.
  - (a) rotation 주기를 조정할지, 비활성화할지
  - (b) Instance Profile에 해당 secret ARN으로 한정한 `secretsmanager:GetSecretValue`를 추가하고 앱이 런타임에 조회하도록 할지
  - (c) master 계정과 별도로 애플리케이션용 DB 계정을 둘지
  - D-003의 보류 범위에 "rotation 정책"이 포함되는지도 명확히 해야 한다.
- **의견 차이**
  - PM과 SRE는 서비스 장애(가용성) 관점을 중심으로 봤다.
  - SEC는 master 계정 공유에 따른 최소 권한 위반을 추가로 지적했다.
- **검증 상태**: 확인된 사실 (기본 rotation 동작), 추론 (운영 시나리오)

## R2-02. SG egress 미정의 (Terraform이 기본 allow-all egress를 제거함)
- **리뷰어**: PM (High), SRE (High)
- **심각도**: High
- **관련 요구사항**: REQ-01, REQ-02, REQ-05, REQ-06, REQ-07, REQ-08
- **관련 결정**: D-005, D-009, D-011, D-022 (SG inbound 정의), D-028 (R1-20 Egress 통제 기각)
- **문제**
  - architecture.md는 모든 SG에 대해 inbound만 정의한다.
  - D-028은 egress를 "통제"하자는 제안을 기각한 것이다. egress를 "전체 허용"한다는 결정은 어디에도 기록되어 있지 않다.
- **근거**
  - 사실: Terraform `aws_security_group`은 생성 시 AWS 기본 allow-all egress 규칙을 제거한다. egress가 필요하면 명시적으로 정의해야 한다(Provider 문서 "NOTE on Egress rules").
  - 사실: 프로젝트 CLAUDE.md §4에 따라 명세에 없는 설정은 Terraform 구현에서 임의로 보완하지 않는다.
- **영향**: egress가 비어 있으면 다음 경로가 모두 차단되어 서비스가 실행되지 않는다.
  - NLB → ALB, ALB → App:8080
  - App → RDS, Redis, Loki
  - App·로그 서버 → NAT
  - Agent → CodeDeploy·S3
  - Bastion → 내부 리소스
- **권장 조치**
  - D-028의 R1-20 기각이 "egress는 0.0.0.0/0 전체 허용"이라는 뜻인지 확인한다.
  - 확인한 내용을 architecture.md 또는 infrastructure-spec.md에 SG별 egress 정책으로 명시한다.
- **검증 상태**: 확인된 사실

## R2-03. ALB Listener Rule, Target Group 담당 주체와 default Forward 대상 미정의
- **리뷰어**: PM (High), SRE (High), SEC (Medium)
- **심각도**: High
- **관련 요구사항**: REQ-01, REQ-02, REQ-07
- **관련 결정**: D-029 (default action Forward, 대상 미결정), D-035 (443 Listener와 NLB TG 등록은 수동), D-015/R-003 (Admin 공개)
- **문제**
  - D-035의 수동 작업은 "443 Listener 생성"과 "NLB TG에 ALB 등록"뿐이다.
  - 다음 항목은 Terraform이 할지 수동으로 할지 정의되어 있지 않다.
    - Host 헤더 기반 Listener Rule 3개(admin, b2b, b2c)
    - 서비스별 ALB Target Group 3개와 EC2 attachment
  - default Forward 대상 Target Group도 정해지지 않았다.
- **근거**
  - 사실: `aws_lb_listener_rule`은 `listener_arn`이 필수다. Listener를 수동으로 만들면 Rule도 data source나 import 없이는 Terraform으로 만들 수 없다.
  - 사실: Target Group과 attachment는 Listener 없이도 만들 수 있다.
  - 사실: Rule이 없으면 모든 Host 요청이 default action 대상 하나로 전달된다.
  - 사실(SEC): NLB EIP로 직접 들어오는 요청이나 임의 Host로 들어오는 요청은 default action이 처리한다.
- **영향**
  - Rule을 수동 작업 목록에서 빠뜨리면 세 도메인이 모두 한 서비스로 연결되어 REQ-01을 충족하지 못한다.
  - default 대상이 Admin이면, 도메인을 모르는 스캐너도 EIP만으로 Admin에 도달한다. R-003 비고에 이 경로는 언급되어 있지 않다.
  - Listener와 Rule이 IaC 밖에 있으므로 설정을 코드로 검증하거나 재현할 수 없다.
- **권장 조치**
  - 경계를 명시한다. 예: "ALB TG 3개와 EC2 attachment는 Terraform, Listener와 Host Rule 3개는 수동"
  - default Forward 대상 TG를 결정한다. 결정할 때 Admin을 제외할지와 R2-12의 동작을 함께 고려한다.
  - 수동 생성 내역(인증서 ARN, Rule, 정책값)을 기록할 위치를 정한다.
  - 대안(PM, 선택 사항): NS 위임 후 두 번째 apply에서 `aws_acm_certificate_validation`, Listener, Rule을 생성하는 2단계 apply. 이미 수동으로 결정했다면 그대로 유지해도 된다.
  - 참고(SEC): TLS 정책은 기각된 항목이다(R1-19). 다만 콘솔에서 만들 때와 API로 만들 때 기본 정책값이 다를 수 있다는 점은 알아 둘 필요가 있다.
- **의견 차이**
  - PM과 SRE는 REQ-01 미충족 위험을 근거로 High로 판단했다.
  - SEC는 노출 범위 관점에서 Medium으로 판단했다.
- **검증 상태**: 확인된 사실 (Provider 의존성, default action 동작), 추론 (영향)

## R2-04. 수동 IAM의 최소 권한 기준 미정의
- **리뷰어**: SEC (High)
- **심각도**: High
- **관련 요구사항**: REQ-07, REQ-05
- **관련 결정**: D-017 (IAM 수동 구성), D-021, D-005·D-023 (영향을 키우는 요인일 뿐 재제기하지 않음)
- **문제**
  - Instance Profile, CodeDeploy Service Role, GitHub Actions 인증을 모두 수동으로 구성한다.
  - 그런데 각 주체가 어느 리소스에 접근할 수 있는지 정해져 있지 않아, REQ-07 "필요한 최소 권한"을 설계 단계에서 검증할 수 없다.
  - GitHub Actions 인증 방식(OIDC 또는 Access Key)도 정해지지 않았다.
- **근거**
  - 사실: CodeDeploy Agent는 기본 설정에서 appspec hook을 root 권한으로 실행한다.
  - 사실: Access Key는 장기 자격증명이며 GitHub Secrets에 저장된다.
  - 추론: 아티팩트 버킷 쓰기 권한과 `codedeploy:CreateDeployment` 권한을 함께 가진 주체는 앱 서버 3대에서 root로 코드를 실행할 수 있다. 앱 서버는 SG를 공유하므로 RDS와 Redis(AUTH 없음)에도 접근할 수 있다.
- **영향**: 배포 자격증명이 넓은 권한으로 발급된 상태에서 유출되면 공급망 경로로 전체 인프라가 침해될 수 있다.
- **권장 조치**: 수동 구성 방침은 유지하되, 아래 최소 범위를 기준으로 명시할지 결정한다.
  - GitHub Actions: OIDC를 사용하고 `sub`를 특정 repo와 branch로 제한한다. 권한은 아티팩트 버킷 prefix에 대한 `s3:PutObject`와 대상 Application·Deployment Group에 대한 배포 권한으로 한정한다.
  - Instance Profile: 아티팩트 버킷에 대한 `s3:GetObject`만 허용한다. R2-01에서 (b)를 선택하면 해당 secret 읽기 권한을 추가한다.
  - CodeDeploy Service Role: `AWSCodeDeployRole` managed policy를 사용한다.
- **검증 상태**: 확인된 사실 (Agent root 실행), 추론 (공격 경로)

## R2-05. ACM 요청·DNS 검증 담당 주체, 인증서 범위 미정 및 결정 간 기술 불일치
- **리뷰어**: PM (Medium), SRE (Medium)
- **심각도**: Medium
- **관련 요구사항**: REQ-01
- **관련 결정**: D-032, D-033, D-035
- **문제**
  - 다음 항목이 정해지지 않았다.
    - 인증서 범위(SAN 3개 또는 `*.imcommerce.shop`)
    - ACM 인증서를 요청하는 주체(Terraform 또는 수동)
    - DNS 검증 CNAME을 등록하는 주체
  - **결정 간 기술 불일치**: D-035의 배경은 "검증 CNAME, NS 위임이 수동(D-032)"이라고 적혀 있다. 그러나 D-032의 수동 범위는 "서비스 도메인 Alias 레코드, registrar NS 위임"뿐이고 검증 CNAME이 없다. 또 D-033에는 "DNS 검증 레코드 처리 방식 미결정"이라고 되어 있다.
    - 통합 과정 확인: D-035의 배경 문구는 AI가 결정을 기록하면서 작성한 것이다. 엔지니어가 검증 CNAME을 수동으로 처리한다고 결정한 적은 없다.
- **근거**
  - 사실: `aws_acm_certificate`는 발급 완료를 기다리지 않고 생성된다. 발급 완료를 기다리는 것은 `aws_acm_certificate_validation`이다.
  - 사실: 검증 CNAME은 Terraform이 관리하는 zone에 `aws_route53_record`로 생성할 수 있다.
  - 사실: ACM DNS 검증은 요청 후 72시간 안에 완료되지 않으면 타임아웃된다.
  - 추론: 반드시 수동으로 해야 하는 것은 registrar NS 위임뿐이다.
- **영향**
  - 명세 단계에서 인증서 리소스를 누가 관리하는지 판단할 수 없다.
  - 인증서 범위가 잘못 정해지면 해당 도메인에서 TLS 오류가 발생한다.
- **권장 조치**: 인증서 요청 주체, 검증 CNAME 등록 주체, 인증서 범위를 결정하고 D-035의 배경을 정정한다. 결정에 따라 성립 가능한 실행 순서는 다음과 같다(SRE 제안, 추론).
  1. apply로 Hosted Zone 생성
  2. NS 위임
  3. ACM 요청
  4. 검증 CNAME 등록
  5. 인증서 발급 완료
  6. 443 Listener와 Rule 생성
  7. NLB TG에 ALB 등록 후 healthy 확인
  8. Alias 레코드 등록
- **검증 상태**: 확인된 사실 (Provider 동작, 72시간 제한, 문서 불일치)

## R2-06. Subnet별 AZ 배치 미정의
- **리뷰어**: PM (Medium)
- **심각도**: Medium
- **관련 요구사항**: REQ-01, REQ-02, REQ-03
- **관련 결정**: D-008, D-012, D-019
- **문제**: /27 Subnet 8개의 AZ가 정의되어 있지 않다. 다음 제약을 동시에 만족해야 한다.
  - (a) App Subnet(`.32/27`)의 AZ는 ALB Subnet AZ 중 하나여야 한다.
  - (b) RDS Subnet(`.192/27`, `.96/27`)은 서로 다른 AZ에 있어야 한다.
  - (c) NLB Subnet의 AZ는 ALB Subnet AZ 중 하나와 같아야 한다(D-012).
- **근거**
  - 사실: ALB에서 활성화되지 않은 AZ에 있는 target은 `Target.NotInUse` 상태가 된다.
  - 사실: DB Subnet Group에는 2개 이상의 AZ가 필요하다.
- **영향**: AZ를 잘못 배치하면 ALB → EC2 트래픽이 전달되지 않거나 RDS 생성이 실패한다.
- **권장 조치**: Subnet별 AZ(예: 2a/2c)를 표로 확정한다.
- **검증 상태**: 확인된 사실

## R2-07. Grafana SSH 터널 방식과 Loki SG(3000 미허용)의 정합성
- **리뷰어**: SRE (Medium), PM (Low), SEC (Low)
- **심각도**: Medium
- **관련 요구사항**: REQ-06, REQ-07
- **관련 결정**: D-009, D-034/R-004
- **문제**: Loki SG의 inbound는 App SG에서 오는 3100과 Bastion SG에서 오는 22뿐이다. 그런데 "Bastion 경유 SSH 터널"이 구체적으로 어떤 방식인지 정해져 있지 않다.
- **근거**
  - 사실: `ssh -L 3000:<log-ip>:3000 bastion` 방식은 Bastion에서 로그 서버 3000으로 새 연결을 맺으므로 차단된다.
  - 사실: ProxyJump 방식(`ssh -J bastion <log-server> -L 3000:localhost:3000`)은 22만 사용하므로 현재 SG로 동작한다.
- **영향**
  - REQ-06 로그 조회의 유일한 접근 경로가 처음부터 실패할 수 있다.
  - 구현 과정에서 3000 inbound를 임의로 추가할 수 있다. 이 경우 기본 비밀번호로 운영되는 Grafana(R-004)의 노출 범위가 커진다.
- **권장 조치**: ProxyJump와 localhost 포워딩 방식으로 확정해 3000 inbound가 필요 없다는 점을 명시한다. 또는 Bastion SG에서 오는 3000을 허용할지 결정한다.
- **의견 차이**
  - SRE는 로그 접근 경로 자체가 실패할 수 있어 Medium으로 판단했다.
  - PM과 SEC는 문서를 명확히 하는 수준이라 Low로 판단했다.
- **검증 상태**: 확인된 사실 (SG 평가 동작), 추론 (구현 위험)

## R2-08. Terraform과 수동 작업 간 drift, 재생성 시 수동 작업 소실, destroy 실패
- **리뷰어**: SRE (Medium), PM (Medium)
- **심각도**: Medium
- **관련 요구사항**: REQ-01, REQ-05, REQ-06
- **관련 결정**: D-017, D-018, D-020, D-021, D-031, D-032, D-035
- **문제**
  - Agent 설치, Alloy 설정, Instance Profile 연결, Deployment Group, NS 위임, Listener와 Rule이 모두 Terraform 밖에서 이루어진다.
  - 그래서 Terraform이 리소스를 교체하거나 삭제하면 수동 작업이 사라지거나 삭제가 실패할 수 있다.
- **근거**
  - 사실: EC2가 교체되면 수동으로 설치한 Agent와 Alloy 설정이 사라진다. AMI data source에 `most_recent`를 쓰거나 user_data를 변경하면 교체가 일어난다.
  - 추론: Loki EC2가 교체되면 private IP가 바뀌어 앱 3대의 Alloy 설정이 모두 깨진다.
  - 사실: Hosted Zone을 다시 만들면 NS 세트가 바뀐다.
  - 사실: SOA와 NS 외의 레코드가 남아 있는 zone, 사용 중인 Target Group, 비어 있지 않은 S3 버킷은 `force_destroy` 없이는 삭제가 실패한다.
  - 추론: EC2 tag를 수동으로 추가하면 다음 apply에서 Terraform이 이를 제거할 수 있다. 그러면 Deployment Group이 대상을 찾지 못한다.
  - 추가 검증 필요: 수동으로 연결한 Instance Profile을 `aws_instance`가 다음 apply에서 해제하는지.
- **영향**: 수동 구성이 몰래 깨지거나, 단기 인프라를 정리할 때 destroy가 중간에 멈출 수 있다.
- **권장 조치**
  - 서비스별 EC2 tag(예: `Name`)를 명세에 정의해 Deployment Group이 사용하도록 한다. D-031은 식별 기준을 정의하지 않기로 했으므로, 이 항목은 drift를 막는 관점에서만 제기한다.
  - AMI ID를 고정한다.
  - 수동 작업 후 `terraform plan`이 No changes인지 확인하는 절차를 둔다.
  - destroy 전 수동 리소스 정리 절차를 정하거나 `force_destroy` 적용 여부를 결정한다.
- **검증 상태**: 확인된 사실, 추가 검증 필요 (Instance Profile diff)

## R2-09. RDS·Redis TLS 강제에 필요한 앱 설정과 리소스 구성 조건
- **리뷰어**: PM (Medium), SRE (Medium), SEC (Low, 리소스 유형 부분)
- **심각도**: Medium
- **관련 요구사항**: REQ-03, REQ-04, REQ-02, 기술 스택 제약(§2.2)
- **관련 결정**: D-023, D-026
- **문제**: TLS 강제를 적용하려면 클라이언트 설정과 리소스 구성 조건이 필요하다. 그런데 이 조건들이 문서에 없고, 앱 측과 확인한 기록도 없다.
- **근거**
  - 사실: Redis in-transit 암호화를 켜면 평문으로 연결하는 클라이언트는 실패한다. Spring Boot 3.4에서는 `spring.data.redis.ssl.enabled=true`를, `redis-cli`에서는 `--tls`를 지정해야 한다.
  - 사실: RDS TLS 강제는 custom DB Parameter Group의 `require_secure_transport`로 구현한다.
  - 추론: Connector/J 8의 기본값 `sslMode=PREFERRED`는 TLS로 연결하므로 RDS 쪽은 대체로 호환된다.
  - 추가 검증 필요: Redis TLS를 적용하려면 `aws_elasticache_cluster` 대신 `aws_elasticache_replication_group`이 필요한지. SEC에 따르면 Provider 문서에서 cluster의 `transit_encryption_enabled`는 Memcached 대상으로 기술되어 있다.
- **영향**: 앱 설정이 빠지면 기동 실패 → `/healthz` 실패 → ValidateService 실패로 이어져 배포가 실패한다.
- **권장 조치**
  - 앱에서 Redis SSL 설정을 변경해야 하는지 앱 측과 확인한다.
  - 명세에 Parameter Group과 ElastiCache 리소스 유형을 명시한다.
- **검증 상태**: 확인된 사실, 추가 검증 필요 (Redis 리소스 유형)

## R2-10. EC2 소프트웨어 설치 주체, Bastion Key Pair, Public IP 미정의
- **리뷰어**: PM (Medium), SEC (Low), SRE (Low, R2-16에 포함)
- **심각도**: Medium
- **관련 요구사항**: REQ-02, REQ-06, REQ-07
- **관련 결정**: D-011, D-018, D-020, R-001
- **문제**
  - 수동 작업으로 명시된 것은 CodeDeploy Agent 설치와 Alloy label 설정뿐이다.
  - 다음 항목은 누가 설치하는지(user_data 또는 수동) 정해지지 않았다.
    - 앱 서버의 JDK 17과 Alloy
    - 로그 서버의 Loki와 Grafana
  - 다음 항목도 정의되어 있지 않다.
    - Key Pair 생성 방식
    - 내부 서버 접속 방식(ProxyJump 또는 Bastion에 key 보관)
    - Bastion Public IP 할당 방식(자동 할당 또는 EIP)
- **근거**
  - 사실: `key_name`이나 다른 접속 수단이 없으면 SSH로 접근할 수 없다.
  - 사실: Public Subnet에 있어도 public IP가 없으면 인터넷에서 접근할 수 없다.
  - 사실: Terraform `tls_private_key`로 키를 만들면 private key가 state에 평문으로 저장된다. R-001과 같은 유형의 위험이 다시 생긴다.
  - 추론: Bastion에 내부 서버 key를 보관하면 Bastion 침해가 곧 내부 전체 접근으로 이어진다.
- **영향**: REQ-07의 Bastion 경유 접근과 REQ-06의 로그 수집을 구현할 경로가 명세 단계에서 비어 있다.
- **권장 조치**
  - 소프트웨어 설치 주체를 결정한다.
  - Key Pair는 public key만 Terraform에 등록하고, 접속은 ProxyJump 방식으로 할지 결정한다.
  - Bastion IP 할당 방식을 결정한다.
- **의견 차이**: SEC는 이 항목을 key 관리 관점으로 한정해 Low로 판단했다.
- **검증 상태**: 확인된 사실 (Provider 동작, state 저장), 추론 (누락에 따른 영향)

## R2-11. NLB SG 참조와 ALB-type TG의 Client IP 처리 조합 미확인
- **리뷰어**: SRE (Medium)
- **심각도**: Medium
- **관련 요구사항**: REQ-01
- **관련 결정**: D-013, D-022, D-029
- **문제**
  - ALB SG는 NLB SG만 source로 허용한다(D-022).
  - 그런데 ALB-type TG에서 client IP preservation이 어떻게 동작하는지 확인되지 않았다.
  - 이 동작에 따라 SG 참조가 트래픽과 health check 양쪽에 적용되는지도 확인되지 않았다.
- **근거**: 추론. target SG에서 NLB SG를 참조하는 것은 공식 기능이다. 다만 ALB 대상과 client IP를 조합했을 때의 동작은 이번에 확인하지 못했다.
- **영향**: 이 조합이 성립하지 않으면 외부 경로 전체가 차단된다. 다만 수동 등록 시점에 health check 실패로 바로 드러난다.
- **권장 조치**
  - 공식 문서로 확인한 뒤 TG의 `preserve_client_ip` 값을 명세에 명시한다.
  - 수동 등록 직후 TG health 상태를 확인하는 단계를 절차에 포함한다.
- **검증 상태**: 추가 검증 필요

## R2-12. NLB → ALB 헬스 체크가 default 대상 서비스 하나의 상태에 묶임
- **리뷰어**: PM (Medium), SRE (Low)
- **심각도**: Medium
- **관련 요구사항**: REQ-01, REQ-02
- **관련 결정**: D-029
- **문제**: NLB의 HTTPS `/healthz` 헬스 체크는 Host Rule에 매칭되지 않고 default action으로 처리된다. 그래서 NLB TG의 상태는 ALB 전체가 아니라 default 대상 서비스 하나의 상태만 반영한다.
- **근거**
  - 사실: NLB는 모든 target이 unhealthy이면 fail-open으로 동작한다.
  - 추론: 헬스 체크 요청의 Host 헤더는 서비스 도메인이 아니다.
  - 추가 검증 필요: 실제 헬스 체크 요청에 들어가는 Host 값.
- **영향**
  - 트래픽 자체는 fail-open으로 대체로 유지된다.
  - 하지만 default 대상 서비스를 배포하는 동안 NLB TG가 unhealthy로 표시되어 상태 판단을 왜곡한다.
- **권장 조치**: 변경은 권장하지 않는다. R2-03에서 default 대상을 결정할 때 이 동작을 인지하고 수용할지 판단한다.
- **의견 차이**
  - PM은 운영 판단이 왜곡된다는 점을 들어 Medium으로 판단했다.
  - SRE는 트래픽에 영향이 없다는 점을 들어 Low로 판단했다.
- **검증 상태**: 확인된 사실 (fail-open), 추론 (Host 불일치)

## R2-13. Loki 3100이 인증 없이 읽기·쓰기 API를 노출함
- **리뷰어**: SEC (Low)
- **심각도**: Low
- **관련 요구사항**: REQ-06, REQ-07
- **관련 결정**: D-009, D-018
- **문제**: App SG에서 3100을 허용한 목적은 Alloy가 로그를 push하기 위해서다. 그런데 같은 포트에서 query API도 함께 제공된다.
- **근거**
  - 사실: Loki 단일 바이너리 기본 구성은 push와 query를 같은 HTTP 포트로 제공한다.
  - 사실: 기본값은 `auth_enabled: false`다.
  - 추론: 앱 서버 1대가 침해되면 다른 서비스의 로그를 조회할 수 있다. 또 다른 label을 붙여 위조 로그를 주입할 수도 있다. D-018의 정적 label은 로그 무결성을 보장하지 않는다.
- **영향**: 로그의 기밀성과 무결성이 약해지고, 침해 분석의 신뢰도가 떨어진다.
- **권장 조치**
  - MVP 범위에서는 위험을 수용할지만 판단하면 된다.
  - 필요하면 앞단에 reverse proxy를 두고 push 경로만 허용한다.
- **검증 상태**: 확인된 사실 (Loki 기본 동작), 추론 (영향)

## R2-14. Redis와 로그 서버 EBS의 저장 암호화 미정
- **리뷰어**: SEC (Low)
- **심각도**: Low
- **관련 요구사항**: REQ-07
- **관련 결정**: D-023, D-025, D-026
- **문제**
  - 저장 암호화는 RDS에만 결정되었다.
  - ElastiCache 저장 암호화와 로그 서버 EBS(20GiB) 암호화는 정의되지 않았다. 로그 서버 EBS에는 고객 정보가 포함된 로그가 저장될 수 있다.
- **근거**
  - 사실: EBS 기본 암호화는 계정 단위 설정이며 기본값은 꺼져 있다.
  - 추가 검증 필요: ElastiCache 저장 암호화의 기본값은 엔진 버전과 리소스 유형에 따라 다르다.
- **권장 조치**: Redis 저장 암호화와 EBS 암호화의 적용 여부를 결정한다.
- **검증 상태**: 추가 검증 필요

## R2-15. NLB Listener와 Target Group 프로토콜(TCP) 미명시
- **리뷰어**: PM (Low)
- **심각도**: Low
- **관련 요구사항**: REQ-01
- **관련 결정**: D-001
- **문제**: D-001은 "443만 전달"한다고만 정했다. ALB-type TG는 TCP만 지원하므로 NLB에 TLS Listener를 쓰면 이 구성을 만들 수 없다.
- **근거**: 사실. ALB-type TG는 TCP 프로토콜이어야 하며, 포트도 ALB Listener 포트와 같아야 한다.
- **권장 조치**: "NLB Listener와 TG는 모두 TCP/443"으로 명시한다.
- **검증 상태**: 확인된 사실

## R2-16. architecture.md 확정 여부와 본문 반영 누락
- **리뷰어**: PM (Low), SRE (Low), SEC (Low)
- **심각도**: Low
- **관련 요구사항**: 전체
- **관련 결정**: D-001~D-035 전반, D-026, D-029, D-033
- **문제**
  - **확정 여부**: 결정 이력이 있는 항목인데도 REQ-01~05, 07, 08 표의 "확정 여부"가 모두 "미결정"이다. 프로젝트 CLAUDE.md상 infrastructure-spec.md는 아키텍처 승인 후 작성하므로, 명세 착수 조건이 모호하다.
  - **본문 반영 누락 (통합 과정에서 원본 대조로 확인)**
    - D-026에서 "ALB → EC2 구간 암호화는 선택하지 않음"으로 결정했지만 architecture.md 본문에는 반영되지 않았다.
    - D-029의 Forward 대상 미결정, D-033의 인증서 범위 미결정이 본문에 표시되어 있지 않다.
  - **추가 명시 권장 (SEC)**
    - Route Table 항목은 "인터넷 아웃바운드가 필요한 Private Subnet"이라고만 적혀 있어, NAT 경로를 어느 Subnet에 줄지 정해지지 않았다. RDS, Redis, ALB Subnet에 NAT 경로가 필요한지 결정해야 한다.
    - RDS `publicly_accessible = false`를 명시할 것을 권장한다. Terraform 기본값으로도 충족되지만 명시하는 편이 낫다.
- **권장 조치**
  - R2 결정을 반영한 뒤 확정 여부를 갱신한다.
  - 미결정 항목과 수동 작업 목록을 본문 한 곳에 모은다.
- **검증 상태**: 확인된 사실

## R2-17. CodeDeploy Agent의 Ubuntu 24.04 지원, IMDSv2 호환, 수동 설치 순서
- **리뷰어**: PM (Low), SRE (Low)
- **심각도**: Low
- **관련 요구사항**: REQ-05
- **관련 결정**: D-020, D-024, D-031 (Agent의 OS 지원 여부는 정의하지 않음)
- **문제**
  - D-031에 따라 OS 지원 여부는 설계 범위에서 빠졌다. 그러나 Agent를 설치할 수 없으면 REQ-05가 성립하지 않으므로, 구현 가능성 관점에서만 제기한다.
  - Instance Profile 연결과 Agent 설치는 둘 다 수동 작업인데, 순서가 정해지지 않았다.
- **근거**
  - 추가 검증 필요: 공식 지원 OS에 Ubuntu 24.04가 포함되는지, Ruby 3.x와 호환되는지.
  - 추가 검증 필요: IMDSv2 강제 환경(hop limit 기본값 1)에서 Agent가 동작하는지.
  - 추론: Profile 없이 Agent를 기동하면 자격 증명 획득에 실패하고, Agent를 재시작해야 할 수 있다.
- **권장 조치**
  - 설계는 변경하지 않는다.
  - 설치 전에 공식 문서를 확인한다.
  - 수동 절차를 "Instance Profile 연결 → Agent 설치 → `codedeploy-agent` 상태 확인" 순서로 고정한다.
- **검증 상태**: 추가 검증 필요


# 4. 요구사항 충족 현황 (SEC 평가 포함)

| 요구사항 | 평가 |
|---|---|
| REQ-01 | 진입 구조는 성립한다. Listener Rule과 TG의 담당 주체(R2-03), ACM 담당 주체(R2-05), 프로토콜 명시(R2-15)를 확정해야 한다. |
| REQ-02 | 서버 분리와 `/healthz`는 충족한다. AZ 배치(R2-06)와 TLS 클라이언트 설정(R2-09)에 따라 기동이 좌우된다. |
| REQ-03 | 네트워크와 암호화는 충족한다. 앱 DB 계정과 rotation 대응(R2-01)은 해결되지 않았다. |
| REQ-04 | 네트워크 계층은 충족한다. 인증으로 접근 주체를 구분하는 것은 범위 밖이다(D-023). |
| REQ-05 | 배포 성공 판정(D-014)은 성립한다. 수동 절차 순서(R2-17)와 drift(R2-08) 관리가 필요하다. |
| REQ-06 | 수집 구조는 성립한다. Grafana 접근 방식(R2-07)을 명시해야 한다. |
| REQ-07 | 네트워크 통제와 IMDSv2는 충족한다. 최소 권한은 검증할 수 없고(R2-04), Git 미노출은 R2-01의 경로로 위협받는다. egress(R2-02)를 명시해야 한다. |
| REQ-08 | NAT outbound는 정의되어 있다. egress 미정의(R2-02) 시 성립하지 않는다. |


# 5. R1 이후 개선된 점 (세 리뷰어 공통)

- **네트워크 접근 통제**
  - SG source를 SG 참조로 제한했고, Bastion은 /32로 제한했다. App, Loki, RDS, Redis, ALB, NLB SG가 모두 정의되었다.
  - 그 결과 REQ-03, 04, 07의 "필요한 통신만 허용"이 구체화되었다.
- **구성 제약과 보안 설정**
  - RDS Subnet Group의 2개 AZ 제약을 해소했다.
  - IMDSv2, RDS 저장 암호화와 TLS, Redis TLS를 반영했다.
  - password를 Secrets Manager로 이전해 state에 평문이 남지 않는다.
- **배포와 로그 수집**
  - ValidateService에서 `/healthz`로 배포 성공을 판정한다.
  - Alloy 정적 label로 서비스를 구분한다.
- **ACM 순서 문제**: D-027의 순서 문제를 D-033과 D-035로 해소했다.
- **새로 생긴 위험**: Terraform과 수동 작업의 경계가 늘어나면서, 세부 리소스 단위의 경계, 수동 절차의 순서, drift 관리가 새로운 운영 위험이 되었다.


# 6. 엔지니어 결정이 필요한 사항

| 구분 | 항목 |
|---|---|
| 서비스 실행 차단 요인 (명세 전 해소 필요) | R2-02 (SG egress) / R2-03 (Listener Rule·TG 담당 주체, default 대상) / R2-06 (AZ 배치) / R2-01 (rotation 대응) |
| 기존 결정과 관련된 확인 | R2-01 ↔ D-003·D-010·D-017 / R2-02 ↔ D-028 / R2-05 ↔ D-035 배경 정정 / R2-08·R2-17 ↔ D-031 |
| 담당 주체·방식 결정 | R2-04 (IAM 최소 범위) / R2-05 (ACM 요청·검증 CNAME·범위) / R2-07 (Grafana 접근 방식) / R2-10 (설치 주체, Key Pair, Bastion IP) |
| 앱 측 확인 | R2-09 (Redis SSL 설정) |
| 공식 문서 확인 필요 | R2-11 (ALB-type TG의 client IP 처리와 SG 참조) / R2-09 (ElastiCache 리소스 유형) / R2-17 (Agent의 OS 지원) / R2-08 (Instance Profile diff) |
| 위험 수용 여부 | R2-12 / R2-13 / R2-14 |
