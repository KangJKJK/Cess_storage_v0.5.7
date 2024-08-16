#!/bin/bash

# 컬러 정의
export RED='\033[0;31m'
export YELLOW='\033[1;33m'
export GREEN='\033[0;32m'
export NC='\033[0m'  # No Color

# 함수: 명령어 실행 및 결과 확인, 오류 발생 시 사용자에게 계속 진행할지 묻기
execute_with_prompt() {
    local message="$1"
    local command="$2"
    echo -e "${YELLOW}${message}${NC}"
    echo "Executing: $command"
    
    # 명령어 실행 및 오류 내용 캡처
    output=$(eval "$command" 2>&1)
    exit_code=$?

    # 출력 결과를 화면에 표시
    echo "$output"

    if [ $exit_code -ne 0 ]; then
        echo -e "${RED}Error: Command failed: $command${NC}" >&2
        echo -e "${RED}Detailed Error Message:${NC}"
        echo "$output" | sed 's/^/  /'  # 상세 오류 메시지를 들여쓰기하여 출력
        echo

        # 사용자에게 계속 진행할지 묻기
        read -p "오류가 발생했습니다. 계속 진행하시겠습니까? (Y/N): " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo -e "${RED}스크립트를 종료합니다.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}Success: Command completed successfully.${NC}"
    fi
}

# 1. 패키지 업데이트 및 필요한 패키지 설치
execute_with_prompt "패키지 업데이트 및 필요한 패키지 설치 중..." \
    "sudo apt update && sudo apt install -y ca-certificates curl gnupg ufw"

# 2. Docker GPG 키 및 저장소 설정
execute_with_prompt "Docker GPG 키 및 저장소 설정 중..." \
    "sudo install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo 'deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    \$(lsb_release -cs) stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null"

# 3. Docker 설치
execute_with_prompt "Docker 설치 중..." \
    "sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io"

# 4. Docker 서비스 활성화 및 시작
execute_with_prompt "Docker 서비스 활성화 및 시작 중..." \
    "sudo systemctl enable docker && sudo systemctl start docker"

# 5. UFW 방화벽 구성
execute_with_prompt "UFW 방화벽 구성 중..." \
    "sudo ufw enable && \
    sudo ufw allow ssh && \
    sudo ufw allow 22 && \
    sudo ufw allow 4001 && \
    sudo ufw allow 4000/tcp && \
    sudo ufw status"

# 6. CESS nodeadm 다운로드 및 설치
execute_with_prompt "CESS nodeadm 다운로드 중..." \
    "wget https://github.com/CESSProject/cess-nodeadm/archive/v0.5.7.tar.gz"
execute_with_prompt "CESS nodeadm 압축 해제 중..." \
    "tar -xvzf v0.5.7.tar.gz"
execute_with_prompt "CESS nodeadm 설치 중..." \
    "cd cess-nodeadm-0.5.7/ && sudo ./install.sh"

# 사용자 안내 메시지
echo -e "${RED}다음과 같은 안내 메시지가 나오면 노란색과 같이 진행하세요${NC}"
echo -e "${RED}1. Enter cess node mode from 'authority/storage/rpcnode${NC}"
echo -e "${YELLOW}storage${NC}"
echo -e "${RED}2. Enter cess storage listener port${NC}"
echo -e "${YELLOW}엔터${NC}"
echo -e "${RED}3. Enter cess rpc ws-url${NC}"
echo -e "${YELLOW}엔터${NC}"
echo -e "${RED}4. Enter cess storage earnings account${NC}"
echo -e "${YELLOW}리워드를 받을 지갑 주소${NC}"
echo -e "${RED}5. Enter cess storage signature account phrase${NC}"
echo -e "${YELLOW}위와 다른 지갑의 복구문자${NC}"
echo -e "${RED}6. Enter cess storage disk path${NC}"
echo -e "${YELLOW}엔터${NC}"
echo -e "${RED}7. Enter cess storage space, by GB unit${NC}"
echo -e "${YELLOW}200${NC}"
echo -e "${RED}8. Enter the number of CPU cores used for mining${NC}"
echo -e "${YELLOW}Your CPU cores라고 나오는 숫자${NC}"
echo -e "${RED}9. Enter the staking account if you use one account to stake multiple nodes${NC}"
echo -e "${YELLOW}엔터${NC}"
echo -e "${RED}10. Enter the TEE worker endpoints if you have any${NC}"
echo -e "${YELLOW}엔터${NC}"

# 7. CESS 프로필 및 설정 구성
execute_with_prompt "CESS 프로필 및 설정 구성 중..." \
    "sudo cess profile testnet && sudo cess config set"

# 8. CESS 노드 구동 및 Docker 로그 확인
execute_with_prompt "CESS 노드 구동 및 Docker 로그 확인 중..." \
    "sudo cess start && docker logs bucket"

echo -e "${YELLOW}모든 작업이 완료되었습니다. 컨트롤+A+D로 스크린을 종료해주세요.${NC}"
echo -e "${GREEN}스크립트 작성자: kangjk${NC}"
