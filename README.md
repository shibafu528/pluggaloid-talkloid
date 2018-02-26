Pluggaloid-Talkloid
===

[Pluggaloid gem](https://github.com/toshia/pluggaloid) に、クライアント・サーバ型のイベントのリモート送受信機能を追加します。  
1台のPluggaloid インスタンスをサーバに見立てて、クライアントを接続してイベントを購読したり発信できたらどうかな？という試験です。

試験的なものなので、このリポジトリはライブラリの体を成していません。  
ライブラリやPluggaloid/mikutterプラグインとしての体が成せそうになったら、構成をいい感じにします。たぶん。

## モジュール解説

### host.rb, client.rb
サンプルスクリプトです。

### talkloid.rb
Talkloidのコアプラグインです。  
Pluggaloidのイベント機構にフックを仕掛け、Talkloidの持つ通信機構に流します。  
また、リモートから受信したイベントをローカルで実行します。

ここでは具体的な通信方式には関知せず、別のプラグインにイベント形式で定義します。

### talkloid_host.rb
Talkloidのホスト(サーバ)用プラグインです。  
イベントの集約・配信などを担うホストでのみ必要な処理が定義されます。

### talkloid_transport_tcp.rb
TCPソケット通信で、Talkloid同士を接続します。

### talkloid_transport_druby.rb
dRubyライブラリを用いて、2つのTalkloid間を接続します。

