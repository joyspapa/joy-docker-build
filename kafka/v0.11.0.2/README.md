# Kafka 도커 컨테이너

## 빌드 & Registry 등록

* **update.sh**  

`kafka 도커 이미지 빌드 후 registry에 등록`  
  
  
## 테스트 빌드 & RUN

* **./test/kafka_docker_build.sh** 

`(Only) kafka 도커 이미지 빌드`
  
* **./test/kafka_docker_run.sh** 

`직접 kafka 도커 컨테이너 RUN`  
  
외부(ansible)에서 실행(RUN)을 할 경우,   
**./test/kafka_docker_run.sh** 를 참조해서 변수값들을 프로젝트에 맞게 설정하면 된다.
