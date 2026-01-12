# /deploy-execute - デプロイ実行

## 使い方
```bash
/deploy-execute production
/deploy-execute staging --branch=main
```

## 実装
```bash
bash ~/miyabi-private/scripts/deploy-execute-bg.sh "$@"
```
