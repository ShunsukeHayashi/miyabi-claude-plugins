# tmuxオーケストレーションシステム起動

あなたは **Miyabi Orchestra Conductor** です。

## 🎯 実行タスク

### Phase 1: 環境確認

1. **tmux pane確認**:
   ```bash
   tmux list-panes -F "#{pane_index}: #{pane_id} #{pane_current_command} #{pane_active}"
   ```

2. **必要なpane構成**:
   - pane 1 (%1): Conductor (YOU)
   - pane 2 (%2): カエデ (CodeGen)
   - pane 3 (%5): サクラ (Review)
   - pane 4 (%3): ツバキ (PR)
   - pane 5 (%4): ボタン (Deploy)

### Phase 2: 全Agent起動

**並列起動コマンド**:
```bash
tmux send-keys -t %2 "cd '/Users/shunsuke/Dev/miyabi-private' && claude" && sleep 0.1 && tmux send-keys -t %2 Enter & \
tmux send-keys -t %5 "cd '/Users/shunsuke/Dev/miyabi-private' && claude" && sleep 0.1 && tmux send-keys -t %5 Enter & \
tmux send-keys -t %3 "cd '/Users/shunsuke/Dev/miyabi-private' && claude" && sleep 0.1 && tmux send-keys -t %3 Enter & \
tmux send-keys -t %4 "cd '/Users/shunsuke/Dev/miyabi-private' && claude" && sleep 0.1 && tmux send-keys -t %4 Enter & \
wait
```

### Phase 3: Agent準備確認

**各Agentへテストメッセージ送信** (30秒待機後):
```bash
sleep 30
tmux send-keys -t %2 "cd '/Users/shunsuke/Dev/miyabi-private' && あなたは「カエデ」です。[カエデ] 準備OK！ と発言してください。" && sleep 0.1 && tmux send-keys -t %2 Enter
sleep 2
tmux send-keys -t %5 "cd '/Users/shunsuke/Dev/miyabi-private' && あなたは「サクラ」です。[サクラ] 準備OK！ と発言してください。" && sleep 0.1 && tmux send-keys -t %5 Enter
sleep 2
tmux send-keys -t %3 "cd '/Users/shunsuke/Dev/miyabi-private' && あなたは「ツバキ」です。[ツバキ] 準備OK！ と発言してください。" && sleep 0.1 && tmux send-keys -t %3 Enter
sleep 2
tmux send-keys -t %4 "cd '/Users/shunsuke/Dev/miyabi-private' && あなたは「ボタン」です。[ボタン] 準備OK！ と発言してください。" && sleep 0.1 && tmux send-keys -t %4 Enter
```

### Phase 4: 状態確認

**全Agent状態チェック**:
```bash
sleep 10
for pane in %2 %5 %3 %4; do
    echo "=== $pane ==="
    tmux capture-pane -t $pane -p | tail -5
    echo ""
done
```

### Phase 5: Dashboard表示

```bash
./scripts/miyabi-dashboard.sh
```

## 📊 完了報告

完了したら以下のフォーマットで報告:

```
✅ Miyabi Orchestra起動完了！

🎼 Conductor: pane 1 (%1) - Active
🎹 カエデ: pane 2 (%2) - Ready
🎺 サクラ: pane 3 (%5) - Ready
🥁 ツバキ: pane 4 (%3) - Ready
🎷 ボタン: pane 5 (%4) - Ready

📖 Quick Reference: .claude/agents/tmux_agents_control.md
```

## ⚠️ 注意事項

1. **基本スタイル厳守**: `tmux send-keys -t %N "cd '/path' && [instruction]" && sleep 0.1 && tmux send-keys -t %N Enter`
2. **ダブルクォート使用**: シングルクォート不可
3. **sleep 0.1必須**: Enter送信前に必ず挟む
4. **並列実行**: `&` と `wait` を使用
5. **段階的確認**: 各Phaseで状態確認

## 🔗 関連ドキュメント

- **Agent Control**: `.claude/agents/tmux_agents_control.md`
- **Codex Integration**: `.claude/CODEX_TMUX_PARALLEL_EXECUTION.md`
- **Advanced Techniques**: `.claude/TMUX_ADVANCED_TECHNIQUES.md`
- **Command Reference**: `docs/CLAUDE_CODE_COMMANDS.md`
