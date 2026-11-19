# 두 수의 사칙연산과 레지스터 출력

두 정수를 입력받아 덧셈, 뺄셈, 곱셈, 나눗셈을 수행하고 각 연산 직후의 AX, BX, CX, DX 값을 화면에 출력하는 어셈블리 프로그램이다.

## 구현 내용

| 과제 조건 | 구현 |
| --- | --- |
| 두 수 입력 | 키보드에서 정수 두 개 입력 |
| 사칙연산 결과 출력 | 합, 차, 곱, 정수 나눗셈의 몫과 나머지 출력 |
| AX, BX, CX, DX 출력 | 각 연산 직후 값을 저장한 뒤 4자리 16진수로 출력 |
| 0으로 나누는 경우 | 오류 안내 후 정상 종료 |

- 입력 범위: **-32768 ~ 32767**
- 계산 환경: **32비트 x86, MASM 문법, Irvine32 라이브러리**
- 계산에는 EAX, EBX, ECX, EDX를 사용한다. 과제에서 요청한 AX, BX, CX, DX는 각 32비트 레지스터의 하위 16비트이므로 해당 부분을 출력한다.
- 입력을 위 범위로 제한하면 합, 차, 곱과 몫이 모두 부호 있는 32비트 정수에 들어간다. 예를 들어 `-32768 / -1`도 `+32768`로 계산할 수 있다.
- 나눗셈은 소수점 계산이 아니라 **정수 나눗셈**이다. 몫은 0 방향으로 잘리고, 나머지의 부호는 첫 번째 수를 따른다.

## 파일 안내

| 파일 | 용도 |
| --- | --- |
| `Arithmetic.asm` | 제출용 어셈블리 소스 코드 |
| `Arithmetic.exe` | 빌드된 Windows 콘솔 실행 파일 |
| `Arithmetic.sln` | Visual Studio에서 여는 솔루션 |
| `Arithmetic.vcxproj` | Win32 빌드 설정 |
| `build.bat` | MASM으로 빌드하는 배치 파일 |
| `run.bat` | 실행 파일을 실행하고, 없으면 먼저 빌드 |
| `README.md` | 과제 설명과 사용 방법 |

## 실행 방법

압축을 푼 뒤 **`Arithmetic.exe`를 실행**하면 된다. 실행 파일은 Windows용이다. 소스를 수정하여 다시 빌드하려면 아래 방법을 따른다.

### 수업에서 쓰던 MASM 프로젝트가 있는 경우

1. 기존 프로젝트의 실행용 `.asm` 파일을 제외한다. `main`이 있는 소스 파일을 두 개 동시에 빌드하면 안 된다.
2. `Arithmetic.asm`을 프로젝트에 추가한다.
3. 플랫폼을 **Win32 또는 x86**으로 선택한 뒤 빌드하고 실행한다.

### 포함된 Visual Studio 프로젝트를 사용하는 경우

1. Visual Studio의 **C++를 사용한 데스크톱 개발** 구성 요소가 설치되어 있어야 한다.
2. 교재의 Irvine 라이브러리를 `C:\Irvine`에 둔다. 이 폴더에 `Irvine32.inc`, `Irvine32.lib`, `SmallWin.inc`, `VirtualKeys.inc` 등이 있어야 한다.
3. `Arithmetic.sln`을 **Visual Studio**에서 연다.
4. **Debug / Win32**를 선택하고 `Ctrl+F5`로 실행한다.

라이브러리 경로가 다르면 프로젝트 속성의 사용자 매크로 `IrvineDir`을 바꾸거나, 환경 변수 `IRVINE_DIR`에 해당 폴더를 지정한다. 프로젝트 파일 안의 기본 경로를 직접 바꿔도 된다.

**VS Code는 편집기이므로 `.asm` 파일만 열어서 실행할 수는 없다.** MASM과 링커, Irvine 라이브러리가 설치된 Windows 환경에서 `build.bat`을 실행하거나 위 Visual Studio 프로젝트를 사용한다. 배치 파일은 설치된 Visual Studio의 C++ 도구를 찾아 사용한다.

교재 저자의 설치 안내: <https://asmirvine.com/gettingStartedVS2022/index.htm>

## 출력 예시

`12`와 `5`를 입력했을 때의 출력 예시이다. `WriteInt`를 사용하므로 양수에도 `+`가 붙는다.

```text
Two-number arithmetic
Input range: -32768 to 32767
Registers: AX/BX/CX/DX in hexadecimal (low 16 bits)

First number: 12
Second number: 5

Addition: +17
  AX=0011  BX=0005  CX=000C  DX=0000

Subtraction: +7
  AX=0007  BX=0005  CX=000C  DX=0000

Multiplication: +60
  AX=003C  BX=0005  CX=000C  DX=0000

Division - quotient: +2  remainder: +2
  AX=0002  BX=0005  CX=000C  DX=0002

Press any key to exit...
```

## 코드 설명

1. `ReadInt`로 수를 입력받고 범위를 검사한다.
2. `LoadNumbers`가 첫 번째 수를 EAX와 ECX, 두 번째 수를 EBX에 넣고 EDX를 0으로 초기화한다.
3. `ADD`, `SUB`, `IMUL`, `CDQ`와 `IDIV`로 연산한다.
4. `SaveRegisters`가 결과와 AX, BX, CX, DX를 저장한다. 출력 함수에 전달할 문자열 주소를 EDX에 넣기 전에 저장하므로 연산 직후 값을 유지할 수 있다.
5. `WriteInt`로 연산 결과를, `WriteHexB`로 레지스터의 하위 16비트를 출력한다.

BX에는 두 번째 입력값, CX에는 첫 번째 입력값의 하위 16비트가 유지된다. 덧셈과 뺄셈 후 DX는 0이고, 곱셈 후 DX는 EDX의 하위 16비트이다. 나눗셈 후 DX에는 나머지의 하위 16비트가 들어간다. 0으로 나눌 때는 실제 나눗셈을 수행하지 않고 나눗셈 준비 상태의 레지스터를 표시한다.

레지스터 출력은 부호 없는 16진수 비트 표현이다. 예를 들어 `-1`의 하위 16비트는 `FFFF`이다. 결과가 16비트보다 크면 AX에는 하위 16비트만 보이지만, 십진수 결과는 전체 32비트 값을 출력한다.

## GitHub 제출

압축을 푼 뒤 위 파일들을 같은 폴더 구조로 저장소에 올린다. 핵심 제출 파일은 **`Arithmetic.asm`과 `README.md`**이다. 프로젝트 파일과 배치 파일을 함께 올리면 다른 Windows PC에서도 같은 설정으로 빌드할 수 있다. 빌드 중 만들어지는 `.obj`, `.pdb`, `.ilk`, `.vs` 폴더는 소스 제출에 필요하지 않다.

## 검증

공식 Irvine32 헤더와 라이브러리를 사용해 MASM 호환 어셈블러 JWasm으로 어셈블하고 Windows용 PE32 실행 파일로 링크했다. 양수·음수·0·경계값을 포함한 입력 271쌍과 범위 밖 입력의 재입력을 검사했다. 연산 결과와 네 레지스터 출력이 기대값과 일치했다.

실행 검증은 x86 에뮬레이터에서 Windows 콘솔 입출력 함수를 모사해 수행했다. Windows PC에서 직접 실행한 결과나 실제 콘솔 화면을 캡처한 것은 아니다. 포함된 Visual Studio 프로젝트와 배치 파일은 이 환경에서 직접 실행하지 않았다.
