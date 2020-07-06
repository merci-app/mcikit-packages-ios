# mcikit-packages-ios

Esse é um repositório de código aberto, desenvolvido pelo time da Merci, que disponibiliza algumas soluções que ajudarão desenvolvedores a acelerarem o processo de desenvolvimento.

## Módulo OTPAuth

Esse módulo diponibiliza a solução de geração de token (TOTP) a partir de uma url otp-auth. 
A seguir um exemplo de inicilização e acesso ao token gerado:

```swift
let otpAuth = try? OTPAuth("otpauth://totp/XPTO:FOO?issuer=XPTO&algorithm=SHA1&digits=6&period=30&secret=N4SYQORWRZ2TIML5")
otpAuth?.currentToken
```
Tempo restante para gerar outro token:

```swift
let otpAuth = try? OTPAuth("otpauth://totp/XPTO:FOO?issuer=XPTO&algorithm=SHA1&digits=6&period=30&secret=N4SYQORWRZ2TIML5")
otpAuth?.remainingSeconds
```

Também é possível receber os eventos com o token e tempo restante para expiração através de notificação:
```swift
let otp = OTPAuth("otpauth://totp/XPTO:FOO?issuer=XPTO&algorithm=SHA1&digits=6&period=30&secret=N4SYQORWRZ2TIML5")

otpAuth?.startNotificattion()
```

Funcão de referência:
```swift
NotificationCenter.default.addObserver(self, selector: #selector(tokenTick(_:)), name: Notification.Name.OTPAuthNotification.tokenTick, object: otpAuth)

@objc public func tokenTick(_ notification: Notification) {
    let currentToken = notification.userInfo?["CURRENT_PASSWORD"] as? String
    let remainSeconds = notification.userInfo?["REMAINING_SECONDS"] as? String
}
```

Encerrar o envio de notificações:
```swift
otpAuth?.stopNotification()
```

## Módulo OTPAuthUI

### OTPAuthImageView

OTPAuthImageView é uma extensão do UIImageView responsável por gerar o QR code.

Declaração:
```swift
let otpAuthImageView = OTPAuthImageView()
```

Função:
```swift
func generateToken(vat: String, otpAuth: OTPAuth, value: String = "", color: UIColor = .black)
```
Parâmetros:
```
vat     : CPF / CNPJ
otpAuth : instancia do OTPAuth
value   : (opcional) valor do QR code
color   : (opcional) cor do QR code 
```
Exemplo de Uso:
```swift
let otpAuth = try? OTPAuth(from: "otpauth://totp/XPTO:FOO?issuer=XPTO&algorithm=SHA1&digits=6&period=30&secret=N4SYQORWRZ2TIML5")
let cpf: String = "12345678909"
let value: String = "12.14"
otpAuthImageView.generateToken(vat: cpf, otpAuth: otpAuth!, value: value)
```
O código que será usado para gerar o QR Code é composto pelos valores fornecidos seguindo o seguinte padrão:
```
Sem value:
{vat}{otpAuth.CurrentToken}
{12345678909}{597504}

Com value:
{vat}{otpAuth.CurrentToken}{value}
{12345678909}{597504}{0000001214}
```

---
[Merci @ 2020](https://merci.com.br)
