# R1 아키텍처 리뷰 결과

| 항목 | 값 |
|---|---|
| 라운드 | R1 |
| 리뷰 일자 | 2026-11-13 |
| 리뷰 대상 | docs/context.md **v0.2** (2026-11-12), docs/architecture.md **v0.2** (2026-11-13), images/architecture-v0.1.png |
| 리뷰어 | aws-pm-reviewer (PM), security-reviewer (SEC), sre-reviewer (SRE) |
| 상태 | 엔지니어 검토 대기 |

> 이 리뷰 결과는 AI의 제안이며 확정된 설계가 아니다. 엔지니어가 각 발견 사항을 수용, 수정, 거절, 보류, 위험 수용 중 하나로 결정하고, 그 결과를 docs/ai-decision.md에 기록한다.


# 1. 리뷰 수행 방식

- **서브에이전트 정의 대체 실행**
  - `.claude/agents/security-reviewer.md`와 `sre-reviewer.md`는 내용이 없는 빈 파일(0 byte)이고, `aws-pm-reviewer.md`는 파일이 없다.
  - 엔지니어 승인에 따라 docs/reviews/CLAUDE.md §2의 역할 정의를 프롬프트로 사용해 general-purpose 에이전트 3개를 독립적으로 실행했다.
- **독립성**: 세 리뷰어는 리뷰 대상 문서만 읽었다. 다른 리뷰어의 결과와 docs/ai-decision.md는 참고하지 않았다.
- **검증 상태 기준**
  - 문서 내용에 관한 사실(버전, 다이어그램 누락 등)은 통합 과정에서 원본 파일과 대조해 확인했다.
  - AWS·Terraform 동작에 관한 "확인된 사실"은 리뷰어가 분류한 것이다. 이번 라운드에서는 공식 문서와 따로 대조하지 않았다.
- **중복 통합**: 같은 내용의 발견 사항은 하나로 합쳤다. 리뷰어마다 심각도가 다르면 가장 높은 값을 쓰고, 의견 차이를 함께 적었다.
- **기존 결정과의 관계**: 이미 docs/ai-decision.md에 기록된 결정과 관련된 항목은 해당 결정 ID를 표시했다. 리뷰어는 이 결정들을 보지 않고 리뷰했다.


# 2. 요약

| 심각도 | 건수 |
|---|---|
| Critical | 1 |
| High | 6 |
| Medium | 9 |
| Low | 7 |
| 합계 | 23 |

| ID | 심각도 | 제목 | 리뷰어 | 관련 요구사항 | 검증 상태 |
|---|---|---|---|---|---|
| R1-01 | Critical | RDS DB Subnet Group이 2개 AZ 조건을 충족하지 못함 | SRE, PM, SEC | REQ-03 | 확인된 사실 |
| R1-02 | High | 로그 모니터링 서버의 배치, SG, 접근 경로가 정의되지 않음 | PM, SEC, SRE | REQ-06, 07, 08 | 확인된 사실 |
| R1-03 | High | 비밀정보 처리 방식과 애플리케이션 접속 정보 주입 방식이 없음 | PM, SEC, SRE | REQ-07, 03 | 확인된 사실 / 추론 |
| R1-04 | High | Bastion, RDS, Redis의 SG 규칙이 정의되지 않음 | SEC, PM | REQ-03, 04, 07 | 확인된 사실 |
| R1-05 | High | NLB → ALB 연결의 AZ, 헬스 체크, SG, Client IP가 정의되지 않음 | SRE, PM, SEC | REQ-01, 07 | 추가 검증 필요 |
| R1-06 | High | CodeDeploy 배포 성공이 애플리케이션 정상 기동을 보장하지 않음 | SRE | REQ-05, 02 | 확인된 사실 / 추론 |
| R1-07 | High | Admin 서비스가 출발지 제한 없이 인터넷에 공개됨 | SEC | REQ-01, 07 | 추가 검증 필요 |
| R1-08 | Medium | `/healthz` 존재 여부 미확인, 장애 알림 경로 없음 | PM, SRE | REQ-02 | 추가 검증 필요 |
| R1-09 | Medium | 수동 IAM 구성의 의존 관계와 권한 범위가 정의되지 않음 | PM, SEC, SRE | REQ-05, 07 | 확인된 사실 / 추론 |
| R1-10 | Medium | 서비스별 로그 구분을 범위에서 제외해 REQ-06 충족이 불확실함 | PM, SRE | REQ-06 | 추가 검증 필요 |
| R1-11 | Medium | /24 VPC CIDR이 사실상 소진됨 | PM, SRE | REQ-08 | 확인된 사실 |
| R1-12 | Medium | CodeDeploy 구성 단위와 agent 지원 여부가 정의되지 않음 | PM, SRE | REQ-02, 05 | 추가 검증 필요 |
| R1-13 | Medium | ElastiCache Redis의 AUTH와 전송 암호화가 정의되지 않음 | SEC | REQ-04, 07 | 확인된 사실 / 추론 |
| R1-14 | Medium | EC2 IMDSv2가 강제되지 않음 | SEC | REQ-07 | 추가 검증 필요 |
| R1-15 | Medium | 애플리케이션 프로세스 관리 방식이 정의되지 않음 | SRE | REQ-02 | 추론 |
| R1-16 | Medium | Loki 저장소 용량과 retention이 정의되지 않음 | SRE | REQ-06 | 추론 |
| R1-17 | Low | 앱 서버 3대가 SG를 공유해 서비스 간 권한이 분리되지 않음 | SEC | REQ-07 | 추론 |
| R1-18 | Low | 저장 데이터와 내부 구간의 암호화가 정의되지 않음 | SEC | REQ-07 | 확인된 사실 / 추가 검증 필요 |
| R1-19 | Low | ALB TLS 정책과 관리 엔드포인트 노출 범위가 정의되지 않음 | SEC | REQ-01 | 추론 |
| R1-20 | Low | Egress 통제가 정의되지 않음 | SEC | REQ-07, 08 | 확인된 사실 / 추론 |
| R1-21 | Low | 서비스당 단일 인스턴스를 in-place로 배포해 다운타임이 발생함 | SRE | REQ-05 | 확인된 사실 / 추론 |
| R1-22 | Low | Route 53 / ACM 전제 조건이 명시되지 않음 | SRE | REQ-01 | 추가 검증 필요 |
| R1-23 | Low | 다이어그램 표현 오류와 문서 버전 불일치 | PM, SRE, SEC | 해당 없음 | 확인된 사실 |


# 3. 발견 사항 상세

## R1-01. RDS DB Subnet Group이 2개 AZ 조건을 충족하지 못함
- **리뷰어**: SRE (Critical), PM (High), SEC (참고)
- **심각도**: Critical
- **관련 요구사항**: REQ-03
- **문제**: 다이어그램에서 RDS용 Private Subnet은 `192.168.0.192/27` 하나뿐이다. architecture.md에도 subnet별 AZ 배치가 정의되어 있지 않다.
- **근거**
  - 사실: RDS DB Subnet Group은 Single-AZ 인스턴스여도 서로 다른 AZ의 subnet을 2개 이상 포함해야 한다.
  - 사실: ElastiCache Subnet Group은 subnet 1개로도 만들 수 있다.
- **영향**: Terraform apply 단계에서 RDS 생성이 실패한다.
- **권장 조치**
  - 다른 AZ에 RDS용 subnet을 하나 더 확보한다.
  - 모든 subnet의 AZ 매핑을 architecture.md에 명시한다.
  - 이 조치는 R1-11(CIDR 소진), R1-02(로그 서버 subnet)와 함께 결정해야 한다.
- **의견 차이**
  - SRE는 배포 자체가 불가능해지므로 Critical로 판단했다.
  - PM은 설계 수정으로 해소할 수 있으므로 High로 판단했다.
  - SEC는 이 문제를 우회하려고 public subnet을 섞어 쓰지 않도록 주의할 것을 덧붙였다.
- **검증 상태**: 확인된 사실

## R1-02. 로그 모니터링 서버의 배치, SG, 접근 경로가 정의되지 않음
- **리뷰어**: PM (High), SRE (High), SEC (Medium)
- **심각도**: High
- **관련 요구사항**: REQ-06, REQ-07, REQ-08
- **관련 기존 결정**: D-007 (다이어그램과 본문을 모두 수정하지 않기로 함)
- **문제**
  - architecture.md는 별도의 로그 모니터링 EC2를 "결정" 상태로 명시한다. 하지만 다이어그램에는 이 서버와 서버가 놓일 subnet이 없다.
  - 다음 항목이 정의되어 있지 않다.
    - Alloy → Loki 수집 포트 허용 (기본 3100/TCP)
    - 관리자가 Grafana에 접근하는 경로 (기본 3000/TCP)
    - Bastion에서 로그 서버로 가는 SSH 경로
- **근거**
  - 사실: SG에 허용 규칙이 없으면 인바운드가 차단되므로 Alloy의 push가 실패한다.
  - 사실: Loki에는 자체 인증 계층이 없다. Grafana의 초기 관리자 계정은 admin/admin이다.
  - 추론: Grafana가 Private Subnet에 있으므로 접근 경로를 정하지 않으면 REQ-06의 "오류 확인"을 할 수 없다.
- **영향**
  - 로그 수집과 조회가 동작하지 않을 수 있다.
  - 명세·구현 단계에서 SG와 subnet을 추측해 채우게 된다.
  - 로그에 포함된 민감 데이터가 노출될 수 있다.
- **권장 조치**
  - 로그 서버의 subnet과 AZ를 정의한다.
  - Loki SG를 정의한다. 3100은 App SG에서, 22는 Bastion SG에서 오는 트래픽만 허용한다.
  - Grafana는 Bastion을 경유해서만 접근하게 한다(예: SSH 터널). 초기 비밀번호 변경 절차도 정의한다.
- **의견 차이**: SEC는 이 항목을 기능 누락보다 접근 통제 관점의 Medium으로 판단했다.
- **검증 상태**: 확인된 사실 (문서와 다이어그램 불일치), 추론 (영향)

## R1-03. 비밀정보 처리 방식과 애플리케이션 접속 정보 주입 방식이 없음
- **리뷰어**: PM (High), SEC (High), SRE (Medium)
- **심각도**: High
- **관련 요구사항**: REQ-07, REQ-03
- **관련 기존 결정**: D-003 (민감 정보 관리 방식은 배포 후 결정), D-006 (RDS 임시 password 사용), R-001, R-002
- **문제**
  - RDS 임시 password를 어디에 둘지 정해지지 않았다. 후보는 코드, tfvars, 환경변수다.
  - 애플리케이션이 RDS·Redis endpoint와 password를 받는 경로도 없다.
- **근거**
  - 사실: Terraform은 `aws_db_instance.password`를 state에 평문으로 저장한다. `sensitive`는 출력만 가려 준다.
  - 사실: `manage_master_user_password`를 쓰면 password를 Secrets Manager가 관리하므로 state에 password가 남지 않는다.
  - 추론: datasource 설정이 없으면 Spring Boot가 기동에 실패한다. 설정을 Git에 커밋하는 것은 REQ-07로 금지되어 있다.
- **영향**
  - 자격 증명이 Git이나 로컬 파일로 유출될 수 있다.
  - 인프라 배포가 끝나도 애플리케이션을 기동하지 못할 수 있다.
- **권장 조치**: 최종 방식은 나중에 정하더라도 지금 최소한 다음을 정의한다.
  - Terraform에 비밀번호를 하드코딩하지 않는다. `sensitive` 변수와 함께 Git에서 제외한 tfvars나 환경변수를 쓴다.
  - `.gitignore`에 `*.tfstate*`, `*.tfvars`, `.terraform/`를 추가한다.
  - 임시 기간 동안 애플리케이션에 접속 정보를 주입하는 방식을 정한다(예: Bastion을 통해 서버 로컬 env 파일을 수동 배치).
- **의견 차이**
  - PM: "범위에서 제외" 결정 자체가 REQ-07과 충돌한다고 봤다.
  - SEC: 범위 결정은 유지하고 최소 장치만 정의하자는 입장이다.
  - SRE: 애플리케이션 기동 불가라는 운영 문제로 보고 Medium으로 판단했다.
- **검증 상태**: 확인된 사실 (Terraform 동작), 추론 (영향)

## R1-04. Bastion, RDS, Redis의 SG 규칙이 정의되지 않음
- **리뷰어**: SEC (High), PM (Low)
- **심각도**: High
- **관련 요구사항**: REQ-03, REQ-04, REQ-07
- **문제**
  - 구체적으로 정의된 SG 규칙은 App SG(ALB SG에서 8080, Bastion SG에서 22)뿐이다.
  - 다음 규칙이 없다.
    - Bastion 22의 허용 출발지
    - RDS 3306과 Redis 6379의 허용 출발지 (App SG, Bastion SG)
  - Bastion의 Public IP 방식과 SSH key pair 관리 방식도 없다.
- **근거**
  - 사실: REQ-03과 REQ-04는 "애플리케이션 서버와 인프라 관리자만" 접근하도록 요구한다.
  - 추론: 출발지가 정의되지 않으면 구현 단계에서 Bastion 22가 `0.0.0.0/0`으로 열릴 가능성이 높다.
- **영향**: Bastion이 침해되면 내부 전체로 접근이 확산될 수 있다. 관리자가 DB와 Redis에 접근하지 못할 수도 있다.
- **권장 조치**
  - Bastion 22는 관리자 고정 IP(/32)에서만 허용한다.
  - RDS와 Redis는 App SG와 Bastion SG만 출발지로 허용하고, CIDR 기반 허용은 쓰지 않는다.
  - Bastion의 Public IP 방식(EIP 여부)과 key pair 보관 주체를 정의한다.
- **의견 차이**: PM은 이 항목을 문서 누락으로 보고 Low로 판단했다. SEC는 구현 단계에서 과도하게 허용될 위험을 들어 High로 판단했다.
- **검증 상태**: 확인된 사실 (문서 누락), 추론 (구현 위험)

## R1-05. NLB → ALB 연결의 AZ, 헬스 체크, SG, Client IP가 정의되지 않음
- **리뷰어**: SRE (High), PM (Medium), SEC (Medium)
- **심각도**: High
- **관련 요구사항**: REQ-01, REQ-07
- **문제**
  - NLB는 Public Subnet 1개(`.128/27`)에, ALB는 Private Subnet 2개(`.64/27`, `.224/27`)에 있다. 각 subnet의 AZ는 명시되어 있지 않다.
  - 다음 항목이 정의되어 있지 않다.
    - NLB Cross-Zone 설정
    - ALB-type Target Group의 헬스 체크
    - ALB default action
    - NLB SG 연결 여부
    - ALB SG 인바운드 출발지
    - Client IP 보존 방식
- **근거**
  - 사실: ALB-type Target Group은 TCP만 지원한다. Target Group 포트는 ALB 리스너 포트와 같아야 한다.
  - 사실: NLB SG는 NLB를 생성할 때만 연결할 수 있다. 나중에 추가하려면 NLB를 다시 만들어야 한다.
  - 사실: ALB는 Proxy Protocol을 지원하지 않는다.
  - 사실: NLB 헬스 체크 요청은 Host 헤더가 서비스 도메인이 아니어서 ALB default action이 응답한다.
  - 추론: default action의 응답 코드와 NLB 헬스 체크 matcher가 맞지 않으면 NLB가 ALB를 unhealthy로 판단한다.
  - 추가 검증 필요
    - NLB의 AZ와 ALB 노드의 AZ가 다를 때의 동작
    - ALB-type 대상에서 Client IP가 보존되는지
- **영향**: 리소스는 정상 생성되지만 외부 트래픽이 ALB에 도달하지 못해 서비스 전체가 접근 불가가 될 수 있다. 생성 시점에 정해야 하는 설정을 놓치면 NLB를 재생성해야 한다.
- **권장 조치**
  - NLB subnet의 AZ를 ALB subnet AZ 중 하나와 맞추고 Cross-Zone 사용 여부를 명시한다.
  - NLB 헬스 체크(protocol, path, matcher)와 ALB default action을 함께 정의한다.
  - NLB SG 사용 여부를 생성 전에 결정한다. ALB SG 인바운드는 NLB 출처로만 한정한다.
  - Client IP 보존 동작은 공식 문서나 PoC로 확인한다.
- **의견 차이**: SRE는 서비스 전체가 불통될 수 있어 High로 판단했다. PM과 SEC는 설정 누락 수준으로 보고 Medium으로 판단했다.
- **검증 상태**: 확인된 사실 (구성 제약), 추가 검증 필요 (AZ 불일치 동작, Client IP)

## R1-06. CodeDeploy 배포 성공이 애플리케이션 정상 기동을 보장하지 않음
- **리뷰어**: SRE (High)
- **심각도**: High
- **관련 요구사항**: REQ-05, REQ-02
- **문제**: CodeDeploy로 배포 성공과 실패를 확인한다고만 되어 있고, 무엇을 성공으로 볼지 기준이 정의되어 있지 않다.
- **근거**
  - 사실: EC2 in-place 배포에서 CodeDeploy는 appspec lifecycle hook 스크립트의 종료 코드만으로 성공과 실패를 판정한다.
  - 추론: ValidateService 단계에서 헬스 체크를 하지 않으면, JAR가 기동 직후 종료되어도 "Succeeded"로 표시된다.
- **영향**: 서비스가 중단된 상태에서도 배포 성공으로 표시되어 REQ-05의 "실패 확인"을 충족하지 못한다.
- **권장 조치**
  - appspec ValidateService에서 `localhost:8080/healthz`를 재시도하며 확인하고, 실패하면 non-zero로 종료한다.
  - GitHub Actions에서 CodeDeploy 배포 상태를 조회해 workflow 결과에 반영한다.
- **검증 상태**: 확인된 사실 (판정 방식), 추론 (영향)

## R1-07. Admin 서비스가 출발지 제한 없이 인터넷에 공개됨
- **리뷰어**: SEC (High)
- **심각도**: High
- **관련 요구사항**: REQ-01, REQ-07
- **문제**: admin.imcommerce.shop은 b2c와 같은 진입점으로 인터넷 전체에 공개된다. Admin에만 적용하는 접근 통제가 정의되어 있지 않다.
- **근거**
  - 추론: 관리자 기능은 brute-force, credential stuffing, 스캐닝의 주요 대상이다.
  - 추가 검증 필요: context.md에는 Admin을 누가 어디서 접근하는지 정의되어 있지 않다. 따라서 공개가 의도된 것인지 판단할 수 없다.
- **영향**: Admin이 침해되면 상품, 주문, 회원 데이터 전체에 영향이 간다.
- **권장 조치**
  - Admin 접근 대상을 확인한다.
  - 접근 제한이 필요하면 ALB listener rule에 `host-header`와 `source-ip` 조건을 함께 건다. 허용되지 않은 출발지에는 403을 반환한다.
  - 이 방식은 ALB가 실제 Client IP를 볼 수 있어야 하므로 R1-05의 확인 결과에 따라 달라진다.
- **검증 상태**: 추가 검증 필요 (요구사항 확인)

## R1-08. `/healthz` 존재 여부 미확인, 장애 알림 경로 없음
- **리뷰어**: PM (Medium), SRE (Medium)
- **심각도**: Medium
- **관련 요구사항**: REQ-02
- **문제**
  - ALB 헬스 체크 경로가 `/healthz`로 정해져 있다. 하지만 애플리케이션이 이 경로를 제공하는지 확인되지 않았다.
  - 장애를 알려 주는 경로(Alarm, Alert)가 없다.
- **근거**
  - 사실: Spring Boot Actuator의 기본 경로는 `/actuator/health`이다.
  - 사실: Target Group의 모든 대상이 unhealthy이면 ALB는 fail-open으로 모든 대상에 계속 라우팅한다. 서비스당 대상이 1대이므로 헬스 체크는 트래픽 차단 기능을 하지 못하고 상태 표시 용도에 그친다.
  - 추론: context.md는 애플리케이션 코드의 대규모 변경을 범위에서 제외한다.
- **영향**
  - `/healthz`가 없으면 모든 대상이 unhealthy로 표시된다.
  - 콘솔을 직접 확인하기 전까지 장애를 알 수 없다.
- **권장 조치**
  - 세 서비스에 `/healthz`가 구현되어 있는지 확인한다. 없으면 Actuator 경로로 대체할지 결정한다.
  - REQ-02의 "정상 실행 확인"을 콘솔 조회로 충족할지, 알림까지 요구할지 결정한다.
- **검증 상태**: 추가 검증 필요

## R1-09. 수동 IAM 구성의 의존 관계와 권한 범위가 정의되지 않음
- **리뷰어**: PM (Medium), SEC (Medium), SRE (Medium)
- **심각도**: Medium
- **관련 요구사항**: REQ-05, REQ-07
- **문제**: IAM을 범위에서 제외한 결정 자체는 요구사항과 충돌하지 않는다(세 리뷰어 공통 의견). 하지만 다음 항목이 정의되어 있지 않다.
  - 필요한 IAM 리소스의 목록과 각 권한 범위
    - EC2 Instance Profile (S3 아티팩트 읽기, CodeDeploy agent)
    - CodeDeploy Service Role
    - GitHub Actions 인증 방식 (OIDC 또는 Access Key)
  - Terraform이 이 리소스들을 참조하는 방식
  - S3 아티팩트 버킷의 보안 설정
- **근거**
  - 사실: CodeDeploy agent는 Instance Profile 권한으로 S3 아티팩트를 내려받고 CodeDeploy API를 polling한다.
  - 추론: GitHub Actions가 장기 Access Key를 쓰다가 유출되면, 아티팩트 변조로 전체 서버에 임의 코드가 배포될 수 있다.
- **영향**: 첫 배포가 권한 오류로 실패할 수 있다. 최소 권한이 적용됐는지 검증할 근거가 없다.
- **권장 조치**
  - 수동 IAM 리소스 목록을 만들고, 각 리소스를 Terraform에서 참조할 방식(이름이나 ARN을 변수로 받기)을 명시한다.
  - GitHub Actions 인증은 OIDC를 검토한다.
  - S3 Public Access Block을 명세에 포함할지 검토한다.
- **검증 상태**: 확인된 사실 (권한 필요성), 추론 (영향)

## R1-10. 서비스별 로그 구분을 범위에서 제외해 REQ-06 충족이 불확실함
- **리뷰어**: PM (Medium), SRE (Medium)
- **심각도**: Medium
- **관련 요구사항**: REQ-06
- **관련 기존 결정**: D-002 (서비스별 로그 구분은 애플리케이션 코드에서 처리)
- **문제**
  - 애플리케이션 로그에 서비스 식별자가 포함되는지 확인되지 않았다.
  - Alloy, Loki, Grafana를 어떤 방식으로 설치하고 설정할지(user_data 또는 수동)도 정의되어 있지 않다.
- **근거**: 추론. 서비스별로 서버가 분리되어 있으므로 Alloy에 서버별 정적 label(예: `service=admin`)을 붙이면 코드 변경 없이 서비스를 구분할 수 있다. 반대로 식별자도 label도 없으면 서비스를 구분할 수 없다.
- **영향**: 장애가 발생했을 때 어느 서비스의 문제인지 특정하기 어렵다.
- **권장 조치**
  - 로그에 서비스 식별자가 포함되는지 확인한다.
  - 포함되지 않으면 Alloy label 부여를 설정 범위에 넣을지 결정한다.
- **검증 상태**: 추가 검증 필요

## R1-11. /24 VPC CIDR이 사실상 소진됨
- **리뷰어**: PM (Medium), SRE (R1-01에서 언급)
- **심각도**: Medium
- **관련 요구사항**: REQ-08
- **문제**
  - `192.168.0.0/24`를 /27 8개로 나누면 7개가 이미 사용 중이고 `.96/27` 하나만 남는다.
  - 그런데 RDS 두 번째 subnet(R1-01)과 로그 서버 subnet(R1-02)이 추가로 필요하다.
- **근거**: 사실. 다이어그램의 CIDR 할당이 그렇다.
- **영향**: 리소스를 기존 subnet에 함께 배치하거나 CIDR을 다시 설계해야 한다.
- **권장 조치**: 다음 중 하나를 고른다.
  - 로그 서버를 App subnet에 함께 두고 `.96/27`을 RDS 두 번째 subnet으로 쓴다.
  - VPC CIDR을 확장한다(/23 또는 Secondary CIDR).
- **검증 상태**: 확인된 사실

## R1-12. CodeDeploy 구성 단위와 agent 지원 여부가 정의되지 않음
- **리뷰어**: PM (Medium), SRE (Low)
- **심각도**: Medium
- **관련 요구사항**: REQ-02, REQ-05
- **문제**
  - 서비스별 Application과 Deployment Group의 구성이 정의되어 있지 않다.
  - 배포 대상 EC2를 식별하는 기준(태그 등)이 정의되어 있지 않다.
  - agent 설치 방식이 정의되어 있지 않다.
  - agent가 Ubuntu 24.04를 지원하는지 확인되지 않았다.
- **근거**
  - 사실: CodeDeploy는 Deployment Group 단위로 배포한다.
  - 사실: agent는 CodeDeploy endpoint를 HTTPS로 polling하는 pull 방식이며, NAT 경로가 필요하다.
  - 추가 검증 필요: agent의 Ubuntu 24.04 공식 지원 여부와 Ruby 버전 호환성.
- **영향**: 배포 대상이 잘못 지정되면 다른 서비스 서버에 배포될 수 있다. agent 설치가 실패하면 배포할 수 없다.
- **권장 조치**
  - 서비스별 Deployment Group과 EC2 태그 기준을 정의한다.
  - agent 설치 방식과 지원 OS를 확인한다.
  - App subnet의 NAT 경로를 명시한다.
- **의견 차이**: SRE는 agent 문제만 따로 보고 Low로 판단했다.
- **검증 상태**: 추가 검증 필요

## R1-13. ElastiCache Redis의 AUTH와 전송 암호화가 정의되지 않음
- **리뷰어**: SEC (Medium)
- **심각도**: Medium
- **관련 요구사항**: REQ-04, REQ-07
- **문제**: Redis의 AUTH(RBAC)와 in-transit TLS 적용 여부가 정해지지 않았다. 현재 접근 통제는 SG 하나뿐이다.
- **근거**
  - 사실: Terraform에서 `transit_encryption_enabled`와 `at_rest_encryption_enabled`는 명시하지 않으면 비활성이다.
  - 사실: `auth_token`을 쓰려면 transit encryption을 켜야 한다.
  - 추론: 앱 서버 3대가 같은 SG를 쓰므로 한 대만 침해되어도 Redis에 인증 없이 접근할 수 있다.
- **영향**: 캐시 데이터가 노출되거나 변조될 수 있다. Redis에 세션을 저장한다면 인증을 우회할 수 있다.
- **권장 조치**
  - Redis에 저장하는 데이터(세션 포함 여부)를 확인한다.
  - AUTH와 TLS 적용 여부를 결정한다. 적용하면 Spring 설정도 함께 변경해야 한다.
  - auth_token도 R1-03과 마찬가지로 state에 평문으로 저장된다.
- **검증 상태**: 확인된 사실 (Terraform 기본값), 추론 (영향)

## R1-14. EC2 IMDSv2가 강제되지 않음
- **리뷰어**: SEC (Medium)
- **심각도**: Medium
- **관련 요구사항**: REQ-07
- **문제**: 인터넷에 공개된 앱 서버에 Instance Metadata 설정이 정의되어 있지 않다.
- **근거**
  - 추론: IMDSv1이 허용된 상태에서 SSRF 취약점이 있으면 Instance Profile 자격 증명이 탈취될 수 있다.
  - 추가 검증 필요: Ubuntu 24.04 공식 AMI의 `ImdsSupport` 기본값.
- **영향**: 탈취한 자격 증명으로 S3 아티팩트를 변조하면 배포 공급망이 침해된다.
- **권장 조치**: 모든 EC2에 `metadata_options.http_tokens = "required"`를 적용한다.
- **검증 상태**: 추가 검증 필요

## R1-15. 애플리케이션 프로세스 관리 방식이 정의되지 않음
- **리뷰어**: SRE (Medium)
- **심각도**: Medium
- **관련 요구사항**: REQ-02
- **문제**: JAR 실행 방식(systemd 등)이 정의되어 있지 않고, 프로세스가 비정상 종료됐을 때 재기동할지도 정해져 있지 않다.
- **근거**: 추론. 프로세스 관리자가 없으면 프로세스가 종료된 뒤 자동으로 복구되지 않는다.
- **영향**: 프로세스가 종료되면 수동으로 조치할 때까지 서비스가 중단된다.
- **권장 조치**: systemd 기반 실행을 배포 기준으로 삼을지 결정한다.
- **검증 상태**: 추론

## R1-16. Loki 저장소 용량과 retention이 정의되지 않음
- **리뷰어**: SRE (Medium)
- **심각도**: Medium
- **관련 요구사항**: REQ-06
- **문제**: 로그 서버의 EBS 크기와 Loki retention 정책이 정의되어 있지 않다.
- **근거**: 추론. 단일 EC2의 filesystem 저장소는 retention이 없으면 디스크가 계속 찬다.
- **영향**: 운영 중 로그 수집이 알림 없이 중단될 수 있다.
- **권장 조치**: 상세 명세 단계에서 EBS 크기, retention 기간, 디스크 사용률 확인 방법을 정의한다.
- **검증 상태**: 추론

## R1-17. 앱 서버 3대가 SG를 공유해 서비스 간 권한이 분리되지 않음
- **리뷰어**: SEC (Low)
- **심각도**: Low
- **관련 요구사항**: REQ-07
- **관련 기존 결정**: D-005 (앱 서버 3대는 SG 1개를 공유)
- **문제**: 세 서비스가 같은 SG를 쓰기 때문에 RDS와 Redis에 대한 네트워크 접근 권한도 같다. 서비스별 DB 계정을 분리할지도 정의되어 있지 않다.
- **근거**
  - 사실: 현재 App SG 인바운드는 ALB와 Bastion에서만 허용하므로 앱 서버끼리 직접 접근하는 경로는 없다.
  - 추론: 공개 범위가 넓은 b2c가 침해되면 admin과 같은 수준의 네트워크 권한을 얻는다.
- **영향**: 침해 범위(blast radius)를 좁힐 수 없다.
- **권장 조치**: MVP 범위에서는 위험 수용도 가능하다. 서비스별 DB 계정을 분리할지는 확인이 필요하다.
- **검증 상태**: 추론

## R1-18. 저장 데이터와 내부 구간의 암호화가 정의되지 않음
- **리뷰어**: SEC (Low)
- **심각도**: Low
- **관련 요구사항**: REQ-07 (명시된 요구사항은 아님)
- **문제**: 다음 항목이 정의되어 있지 않다.
  - RDS 저장 암호화
  - RDS 연결 TLS 강제
  - ALB → EC2 구간 암호화 (현재 8080 평문 HTTP)
- **근거**
  - 사실: Terraform에서 `storage_encrypted`의 기본값은 false이며, 생성 후에는 바로 바꿀 수 없다.
  - 추가 검증 필요: `require_secure_transport`의 기본값.
- **영향**: 스토리지나 스냅샷이 노출되면 데이터가 그대로 읽힌다. VPC 내부 구간이 스니핑될 수 있다.
- **권장 조치**: 최소한 `storage_encrypted`는 RDS 생성 전에 결정한다.
- **검증 상태**: 확인된 사실 (Terraform 기본값), 추가 검증 필요

## R1-19. ALB TLS 정책과 관리 엔드포인트 노출 범위가 정의되지 않음
- **리뷰어**: SEC (Low)
- **심각도**: Low
- **관련 요구사항**: REQ-01
- **문제**: 다음 항목이 정의되어 있지 않다.
  - ALB TLS security policy
  - 공개 ALB를 통해 Spring Boot actuator 계열 엔드포인트가 노출되는 범위
  - 등록되지 않은 Host로 요청이 들어올 때의 처리 (R1-05의 default action과 연관)
- **근거**: 추론. actuator 노출 설정에 따라 내부 정보가 공개될 수 있다.
- **권장 조치**
  - default action은 fixed-response로 둔다.
  - 최신 TLS 정책을 명시한다.
  - 헬스 체크 외의 관리 엔드포인트를 차단하는지 확인한다.
- **검증 상태**: 추론

## R1-20. Egress 통제가 정의되지 않음
- **리뷰어**: SEC (Low)
- **심각도**: Low
- **관련 요구사항**: REQ-07, REQ-08
- **문제**: SG 아웃바운드 정책이 정의되어 있지 않다.
- **근거**
  - 사실: SG의 기본 egress는 `0.0.0.0/0` 전체 허용이다.
  - 추론: 침해가 발생하면 유출 경로를 막을 수 없다.
- **권장 조치**: MVP에서는 위험 수용도 가능하다. RDS, Redis, ALB처럼 외부 통신이 필요 없는 리소스는 egress 제한을 검토한다.
- **검증 상태**: 확인된 사실 (기본값), 추론

## R1-21. 서비스당 단일 인스턴스를 in-place로 배포해 다운타임이 발생함
- **리뷰어**: SRE (Low)
- **심각도**: Low
- **관련 요구사항**: REQ-05
- **문제**: 서비스별 EC2가 1대이므로 in-place 배포 중에는 해당 서비스가 중단된다.
- **근거**
  - 사실: CodeDeploy의 LB 연동을 켜면 배포 중 대상이 deregister된다.
  - 사실: deregistration delay의 기본값은 300초다.
- **영향**: 배포할 때마다 몇 분간 서비스가 중단된다. MVP 범위에서는 수용 가능한 수준으로 판단했다.
- **권장 조치**: 다운타임을 수용할지 결정한다. LB 연동을 사용한다면 deregistration delay를 짧게 설정하는 것을 검토한다.
- **검증 상태**: 확인된 사실 (기본 동작), 추론 (영향)

## R1-22. Route 53 / ACM 전제 조건이 명시되지 않음
- **리뷰어**: SRE (Low)
- **심각도**: Low
- **관련 요구사항**: REQ-01
- **문제**: 다음 전제 조건이 명시되어 있지 않다.
  - imcommerce.shop의 Public Hosted Zone과 registrar의 NS 위임 상태
  - ACM 인증서의 범위(SAN 3개 또는 wildcard)
  - ACM 인증서의 검증 방식
- **근거**
  - 사실: ACM 인증서는 ALB와 같은 리전에 있어야 하며, DNS 검증을 마쳐야 발급된다.
  - 사실: Route 53 Alias 레코드로 NLB를 가리킬 수 있다.
- **영향**: NS 위임이나 인증서 검증이 끝나지 않으면 HTTPS로 접근할 수 없다.
- **권장 조치**: 도메인 위임 상태, 인증서 범위, DNS 검증 방식을 명시한다.
- **검증 상태**: 추가 검증 필요 (현재 도메인 상태)

## R1-23. 다이어그램 표현 오류와 문서 버전 불일치
- **리뷰어**: PM (Low), SRE (Low), SEC (참고)
- **심각도**: Low
- **관련 요구사항**: 해당 없음
- **문제**
  - **다이어그램**
    - Route 53, ACM, S3, CodeDeploy가 VPC 안에 그려져 있다. 실제로는 리전 또는 글로벌 서비스다.
    - "Rotue53" 오타가 있다.
    - Route 53 → NLB, ACM → ALB 연결선이 없다.
    - Bastion → 내부 리소스 경로가 표시되어 있지 않다.
    - CodeDeploy → EC2 화살표가 실제 동작(agent가 pull하는 방식)과 반대 방향이다.
    - subnet별 AZ가 표기되어 있지 않다.
  - **버전**: context.md는 **v0.2**인데 architecture.md는 "요구사항 기준"을 `context.md(v0.1)`로 적고 있다. 다이어그램 파일명도 v0.1이다.
- **근거**: 사실. 통합 과정에서 원본 파일과 대조해 확인했다.
- **영향**
  - 명세 단계에서 네트워크 경로(NAT, VPC Endpoint 필요 여부)를 잘못 판단할 수 있다.
  - 리뷰와 결정 이력의 기준 버전이 모호해진다.
- **권장 조치**
  - 다이어그램을 갱신할 때 위 항목을 반영한다.
  - architecture.md의 "요구사항 기준" 버전을 정정한다.
- **검증 상태**: 확인된 사실


# 4. 공통 긍정 평가

세 리뷰어가 공통으로 다음을 긍정적으로 평가했다.
- **진입 구조**: NLB(EIP)로 들어와 ALB에서 TLS 종료와 Host 기반 라우팅을 하는 구조는 고정 IP, 도메인별 라우팅, HTTPS 요구사항(REQ-01)을 함께 충족한다. PM은 대안으로 Global Accelerator 등을 검토했고, 운영 요소만 늘어나므로 구조 변경을 권장하지 않았다.
- **HTTP 차단**: 80 Listener를 두지 않는 방식으로 단순하게 처리했다.
- **네트워크 배치**: ALB, App, DB, Redis, 로그 서버를 Private Subnet에 두고 NAT를 통한 outbound만 허용해 외부 노출 면이 작다.
- **MVP 적합성**: 관리형 서비스, 단일 NAT, 서비스별 EC2 분리로 MVP 범위와 운영 복잡도 최소화 제약에 맞췄고, 과도한 HA는 없다.
- **App SG**: 인바운드를 SG 참조 방식(ALB SG → 8080, Bastion SG → 22)으로 최소화했다.


# 5. 엔지니어 결정이 필요한 사항

| 구분 | 항목 |
|---|---|
| 배포 차단 요인 (명세 작성 전 해소 필요) | R1-01, R1-11 (subnet, AZ, CIDR 재설계) / R1-05 (NLB → ALB 연결 구성) |
| 기존 결정과 관련된 재검토 요청 | R1-02 ↔ D-007 / R1-03 ↔ D-003, D-006 / R1-10 ↔ D-002 / R1-17 ↔ D-005 |
| 요구사항 확인 필요 (context.md 범위) | R1-07 (Admin 접근 대상) / R1-08 (`/healthz` 존재 여부, 알림 필요 여부) |
| 생성 후 변경이 어려운 설정 | R1-05 (NLB SG) / R1-18 (`storage_encrypted`) |
