#!/bin/bash

# 컬러 정의
export RED='\033[0;31m'
export YELLOW='\033[1;33m'
export GREEN='\033[0;32m'
export NC='\033[0m'  # No Color

# screen 세션을 생성하고 해당 세션 안에서 명령어를 실행하는 함수
execute_in_screen() {
    local message="$1"
    local command="$2"
    echo -e "${YELLOW}${message}${NC}"
    screen -S cess -X stuff "$command$(echo -e '\n')"
}

# 1. screen 설치
echo "Installing screen..."
sudo apt update && sudo apt install -y screen

# 2. 새로운 screen 세션 생성
echo "Creating a new screen session named 'cess'..."
screen -S cess -dm bash

# 3. 패키지 업데이트 및 필요한 패키지 설치
execute_in_screen "Updating packages and installing necessary packages..." \
    "sudo apt update && sudo apt install -y ca-certificates curl gnupg ufw"

# 4. Docker GPG 키 및 저장소 설정
execute_in_screen "Setting up Docker repository..." \
    "sudo install -m 0755 -d /etc/apt/keyrings && \\
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \\
    echo 'deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \\
    \$(lsb_release -cs) stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null"

# 5. Docker 설치
execute_in_screen "Installing Docker..." \
    "sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io"

# 6. Docker 서비스 활성화 및 시작
execute_in_screen "Enabling and starting Docker service..." \
    "sudo systemctl enable docker && sudo systemctl start docker"

# 7. UFW 방화벽 구성
execute_in_screen "Configuring UFW firewall..." \
    "sudo ufw enable && \\
    sudo ufw allow ssh && \\
    sudo ufw allow 22 && \\
    sudo ufw allow 4001 && \\
    sudo ufw allow 4000/tcp && \\
    sudo ufw status"

# 8. CESS nodeadm 다운로드 및 설치
execute_in_screen "Downloading and installing CESS nodeadm..." \
    "wget https://github.com/CESSProject/cess-nodeadm/archive/v0.5.7.tar.gz && \\
    tar -xvzf v0.5.7.tar.gz && \\
    cd cess-nodeadm-0.5.7/ && \\
    ./install.sh"

# 9. CESS 프로필 및 설정 구성
execute_in_screen "Configuring CESS profile..." \
    "sudo cess profile testnet && \\
    sudo cess config set"

# 사용자 안내 메시지
echo -e "${RED}다음과 같은 안내 메시지가 나오면 다음과 같이 진행하세요:${NC}"

echo -e "${RED}Enter cess node mode from 'authority/storage/rpcnode':${NC}"
echo -e "${YELLOW}storage.${NC}"

echo -e "${RED}Enter cess storage listener port:${NC}"
echo -e "${YELLOW}엔터${NC}"

echo -e "${RED}Enter cess rpc ws-url:${NC}"
echo -e "${YELLOW}엔터${NC}"

echo -e "${RED}Enter cess storage earnings account:${NC}"
echo -e "${YELLOW}리워드를 받을 지갑 주소.${NC}"

echo -e "${RED}Enter cess storage signature account phrase:${NC}"
echo -e "${YELLOW}위와 다른 지갑의 복구문자${NC}"

echo -e "${RED}Enter cess storage disk path:${NC}"
echo -e "${YELLOW}엔터${NC}"

echo -e "${RED}Enter cess storage space, by GB unit:${NC}"
echo -e "${YELLOW}200${NC}"

echo -e "${RED}Enter the number of CPU cores used for mining:${NC}"
echo -e "${YELLOW}Your CPU cores라고 나오는 숫자${NC}"

echo -e "${RED}Enter the staking account if you use one account to stake multiple nodes:${NC}"
echo -e "${YELLOW}엔터${NC}"

echo -e "${RED}Enter the TEE worker endpoints if you have any:${NC}"
echo -e "${YELLOW}엔터${NC}"

# 10. CESS 노드 구동 및 Docker 로그 확인
execute_in_screen "Starting CESS node and checking Docker logs..." \
    "sudo cess start && \\
    docker logs bucket"

echo -e "${YELLOW}모든작업이 완료되었습니다.컨트롤+A+D로 스크린을 종료해주세요${NC}"
# 스크립트 작성자: kangjk