<template>
  <div class="game-container">
    <!-- 游戏设置界面 -->
    <div v-if="gameState === 'setup'" class="setup-screen">
      <div class="setup-header">
        <h1 class="game-title">🐾 萌宠算24点 🐾</h1>
        <p class="game-subtitle">线下聚会欢乐游戏</p>
      </div>

      <!-- 游戏规则说明 -->
      <div class="game-rules">
        <h3>🎯 游戏规则</h3>
        <div class="rules-content">
          <div class="rule-item">
            <span class="rule-icon">🎴</span>
            <span>系统随机发放4张牌（A=1, J=11, Q=12, K=13）</span>
          </div>
          <div class="rule-item">
            <span class="rule-icon">🧮</span>
            <span>使用加减乘除和括号计算，使结果等于24</span>
          </div>
          <div class="rule-item">
            <span class="rule-icon">⏰</span>
            <span>每题30秒时间限制，答对基础10分+时间奖励</span>
          </div>
          <div class="rule-item">
            <span class="rule-icon">⚡</span>
            <span>时间奖励：5秒内+5分，10秒内+3分，15秒内+1分</span>
          </div>
          <div class="rule-item">
            <span class="rule-icon">🏆</span>
            <span>轮流答题，游戏结束时按分数排名</span>
          </div>
        </div>
      </div>

      <div class="player-setup">
        <div class="player-count-selector">
          <h3>选择玩家数量</h3>
          <div class="count-buttons">
            <button
              v-for="num in [1,2,3,4,5,6]"
              :key="num"
              :class="['count-btn', { active: playerCount === num }]"
              @click="playerCount = num"
            >
              {{ num }}人
            </button>
          </div>
        </div>

        <div class="player-names">
          <h3>输入玩家名字</h3>
          <div class="name-inputs">
            <div
              v-for="i in playerCount"
              :key="i"
              class="player-input-group"
            >
              <div class="player-avatar">
                <span class="avatar-emoji">{{ playerAvatars[i-1] }}</span>
              </div>
              <input
                v-model="playerNames[i-1]"
                :placeholder="`玩家${i}`"
                class="name-input"
                maxlength="10"
              />
            </div>
          </div>
        </div>

        <button
          class="start-game-btn"
          @click="startGame"
          :disabled="!canStartGame"
        >
          🎮 开始游戏 🎮
        </button>
      </div>
    </div>

    <!-- 游戏进行界面 -->
    <div v-if="gameState === 'playing'" class="game-screen">
      <div class="game-header">
        <div class="round-info">
          <span class="round-number">第 {{ currentRound }} 轮</span>
          <span class="cards-left">{{ remainingCards.length }} 张牌剩余</span>
        </div>

        <div class="timer-container">
          <div class="timer" :class="{ 'time-warning': timeLeft <= 10 }">
            <span class="timer-icon">⏰</span>
            <span class="time-display">{{ timeLeft }}s</span>
          </div>
        </div>

        <button class="end-game-btn" @click="endGame">结束游戏</button>
      </div>

      <div class="game-main">
        <!-- 当前牌面 -->
        <div class="cards-display">
          <div class="card" v-for="card in currentCards" :key="card.id">
            <span class="card-number">{{ card.display }}</span>
            <div class="card-suit">♠️</div>
          </div>
        </div>

        <!-- 当前玩家信息 -->
        <div class="current-player">
          <div class="player-info">
            <span class="player-avatar">{{ playerAvatars[currentPlayerIndex] }}</span>
            <span class="player-name">{{ playerNames[currentPlayerIndex] }}</span>
            <span class="turn-indicator">正在思考...</span>
          </div>
        </div>

        <!-- 答案输入 -->
        <div class="answer-input">
          <input
            v-model="currentAnswer"
            placeholder="输入算式 (如: (A+4)×3-4 或 (8+J)×Q-K)"
            class="expression-input"
            @keyup.enter="submitAnswer"
            ref="answerInput"
          />
          <button class="submit-btn" @click="submitAnswer" :disabled="!currentAnswer.trim()">
            提交答案
          </button>
        </div>

        <!-- 提示信息 -->
        <div v-if="message" class="message" :class="messageType">
          {{ message }}
        </div>
      </div>

      <!-- 玩家分数面板 -->
      <div class="scoreboard">
        <div class="score-header">实时分数</div>
        <div class="score-list">
          <div
            v-for="(player, index) in playerNames"
            :key="index"
            class="score-item"
            :class="{ 'current-turn': index === currentPlayerIndex }"
          >
            <div class="player-score-info">
              <span class="player-avatar-small">{{ playerAvatars[index] }}</span>
              <span class="player-name-small">{{ player }}</span>
            </div>
            <span class="score">{{ playerScores[index] }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 游戏结束界面 -->
    <div v-if="gameState === 'finished'" class="finished-screen">
      <div class="finished-header">
        <h2>🎉 游戏结束 🎉</h2>
        <p>最终排行榜</p>
      </div>

      <div class="final-leaderboard">
        <div
          v-for="(player, index) in sortedPlayers"
          :key="index"
          class="leaderboard-item"
          :class="`rank-${index + 1}`"
        >
          <div class="rank-badge">
            <span v-if="index === 0">👑</span>
            <span v-else-if="index === 1">🥈</span>
            <span v-else-if="index === 2">🥉</span>
            <span v-else>{{ index + 1 }}</span>
          </div>
          <div class="player-info">
            <span class="player-avatar">{{ playerAvatars[player.originalIndex] }}</span>
            <span class="player-name">{{ player.name }}</span>
          </div>
          <div class="final-score">
            {{ player.score }} 分
          </div>
          <div class="player-stats">
            <div class="stat-mini">
              <span class="stat-label">答题:</span>
              <span class="stat-value">{{ player.correct }}/{{ player.attempts }}</span>
            </div>
            <div class="stat-mini">
              <span class="stat-label">正确率:</span>
              <span class="stat-value">{{ player.accuracy }}%</span>
            </div>
          </div>
        </div>
      </div>

      <div class="game-stats">
        <div class="stat-item">
          <span class="stat-label">总轮数：</span>
          <span class="stat-value">{{ currentRound - 1 }}</span>
        </div>
        <div class="stat-item">
          <span class="stat-label">最快答题：</span>
          <span class="stat-value">{{ fastestTime ? `${fastestTime}s` : '无' }}</span>
        </div>
        <div class="stat-item">
          <span class="stat-label">总答题数：</span>
          <span class="stat-value">{{ totalAttempts }}</span>
        </div>
        <div class="stat-item">
          <span class="stat-label">平均正确率：</span>
          <span class="stat-value">{{ averageAccuracy }}%</span>
        </div>
      </div>

      <div class="finished-actions">
        <button class="play-again-btn" @click="resetGame">再玩一次</button>
        <button class="back-to-setup-btn" @click="backToSetup">返回设置</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'TwentyFourGame',
  data() {
    return {
      gameState: 'setup', // setup, playing, finished
      playerCount: 2,
      playerNames: ['', '', '', '', '', ''],
      playerScores: [0, 0, 0, 0, 0, 0],
      playerAvatars: ['🐱', '🐶', '🐰', '🦊', '🐼', '🐨'],
      playerStats: [
        { attempts: 0, correct: 0 },
        { attempts: 0, correct: 0 },
        { attempts: 0, correct: 0 },
        { attempts: 0, correct: 0 },
        { attempts: 0, correct: 0 },
        { attempts: 0, correct: 0 }
      ],
      currentRound: 1,
      currentPlayerIndex: 0,
      currentCards: [],
      remainingCards: [],
      timeLeft: 30,
      timer: null,
      currentAnswer: '',
      message: '',
      messageType: '',
      fastestTime: null,
      roundStartTime: null
    }
  },
  computed: {
    canStartGame() {
      return this.playerNames.slice(0, this.playerCount).every(name => name.trim())
    },
    sortedPlayers() {
      const players = this.playerNames.slice(0, this.playerCount).map((name, index) => {
        const stats = this.playerStats[index]
        return {
          name,
          score: this.playerScores[index],
          originalIndex: index,
          attempts: stats.attempts,
          correct: stats.correct,
          accuracy: stats.attempts > 0 ? Math.round((stats.correct / stats.attempts) * 100) : 0
        }
      })
      return players.sort((a, b) => b.score - a.score)
    },
    totalAttempts() {
      return this.playerStats.slice(0, this.playerCount).reduce((sum, stats) => sum + stats.attempts, 0)
    },
    averageAccuracy() {
      const players = this.playerStats.slice(0, this.playerCount)
      const totalAccuracy = players.reduce((sum, stats) => {
        return sum + (stats.attempts > 0 ? (stats.correct / stats.attempts) * 100 : 0)
      }, 0)
      return players.length > 0 ? Math.round(totalAccuracy / players.length) : 0
    }
  },
  methods: {
    startGame() {
      this.gameState = 'playing'
      this.initializeCards()
      this.startNewRound()
    },

    initializeCards() {
      // 创建52张牌：每种数字4张（A=1, 2-10, J=11, Q=12, K=13）
      this.remainingCards = []
      for (let num = 1; num <= 13; num++) {
        for (let i = 0; i < 4; i++) {
          this.remainingCards.push({
            id: `${num}-${i}`,
            value: num,
            display: this.getCardDisplay(num)
          })
        }
      }
      // 洗牌
      this.shuffleCards()
    },

    shuffleCards() {
      for (let i = this.remainingCards.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [this.remainingCards[i], this.remainingCards[j]] = [this.remainingCards[j], this.remainingCards[i]]
      }
    },

    getCardDisplay(value) {
      switch (value) {
        case 1: return 'A'
        case 11: return 'J'
        case 12: return 'Q'
        case 13: return 'K'
        default: return value.toString()
      }
    },

    startNewRound() {
      if (this.remainingCards.length < 4) {
        this.endGame()
        return
      }

      // 发4张牌
      this.currentCards = this.remainingCards.splice(0, 4)
      this.currentAnswer = ''
      this.message = ''
      this.roundStartTime = Date.now()
      this.startTimer()

      // 聚焦到输入框
      this.$nextTick(() => {
        if (this.$refs.answerInput) {
          this.$refs.answerInput.focus()
        }
      })
    },

    startTimer() {
      this.timeLeft = 30
      if (this.timer) clearInterval(this.timer)

      this.timer = setInterval(() => {
        this.timeLeft--
        if (this.timeLeft <= 0) {
          this.timeUp()
        }
      }, 1000)
    },

    timeUp() {
      clearInterval(this.timer)
      this.showMessage('时间到！', 'error')
      setTimeout(() => {
        this.nextPlayer()
      }, 1500)
    },

    submitAnswer() {
      if (!this.currentAnswer.trim()) return

      clearInterval(this.timer)
      const timeUsed = Math.floor((Date.now() - this.roundStartTime) / 1000)

      // 更新答题统计
      this.playerStats[this.currentPlayerIndex].attempts++

      if (this.validateAnswer(this.currentAnswer)) {
        // 答对了 - 计算基础分数和时间奖励
        const baseScore = 10
        const timeBonus = this.calculateTimeBonus(timeUsed)
        const totalScore = baseScore + timeBonus

        this.playerScores[this.currentPlayerIndex] += totalScore
        this.playerStats[this.currentPlayerIndex].correct++

        // 更新最快记录
        if (!this.fastestTime || timeUsed < this.fastestTime) {
          this.fastestTime = timeUsed
        }

        let bonusText = ''
        if (timeBonus > 0) {
          bonusText = ` (+${timeBonus}时间奖励)`
        }

        this.showMessage(`✅ 答对了！用时${timeUsed}秒，获得${totalScore}分${bonusText}！`, 'success')
        setTimeout(() => {
          this.nextRound()
        }, 2000)
      } else {
        // 答错了
        this.showMessage('❌ 答案错误！', 'error')
        setTimeout(() => {
          this.nextPlayer()
        }, 1500)
      }
    },

    validateAnswer(expression) {
      try {
        // 移除所有空格
        let expr = expression.replace(/\s/g, '')

        // 检查是否只包含允许的字符
        if (!/^[\dAJQK+\-*/()]+$/.test(expr)) {
          return false
        }

        // 检查括号匹配
        let bracketCount = 0
        for (let char of expr) {
          if (char === '(') bracketCount++
          if (char === ')') bracketCount--
          if (bracketCount < 0) return false
        }
        if (bracketCount !== 0) return false

        // 转换牌面字符为数字值
        expr = this.convertCardNotation(expr)

        // 检查是否使用了正确的牌
        if (!this.validateUsedCards(expr)) {
          return false
        }

        // 计算表达式的值
        const result = this.calculateExpression(expr)

        // 检查结果是否精确等于24
        return Math.abs(result - 24) < 0.0001
      } catch (e) {
        return false
      }
    },

    convertCardNotation(expr) {
      return expr
        .replace(/A/g, '1')
        .replace(/J/g, '11')
        .replace(/Q/g, '12')
        .replace(/K/g, '13')
    },

    validateUsedCards(expr) {
      // 提取表达式中的所有数字
      const numberRegex = /\d+/g
      const usedNumbers = []
      let match

      while ((match = numberRegex.exec(expr)) !== null) {
        usedNumbers.push(parseInt(match[0]))
      }

      // 获取当前牌的值
      const cardValues = this.currentCards.map(card => card.value).sort()
      const usedSorted = [...usedNumbers].sort()

      // 检查使用的数字是否与发的牌完全匹配（每个数字使用次数不能超过牌的数量）
      const cardCount = {}
      const usedCount = {}

      // 统计发的牌
      cardValues.forEach(value => {
        cardCount[value] = (cardCount[value] || 0) + 1
      })

      // 统计使用的牌
      usedNumbers.forEach(value => {
        usedCount[value] = (usedCount[value] || 0) + 1
      })

      // 检查每个数字的使用次数是否不超过牌的数量
      for (const value of usedNumbers) {
        if ((usedCount[value] || 0) > (cardCount[value] || 0)) {
          return false
        }
      }

      return true
    },

    calculateExpression(expr) {
      // 简单的表达式计算器
      try {
        // 使用Function构造器来计算表达式
        // 注意：这在生产环境中应该更安全
        return Function('"use strict"; return (' + expr + ')')()
      } catch (e) {
        throw new Error('Invalid expression')
      }
    },

    calculateTimeBonus(timeUsed) {
      // 时间奖励机制
      if (timeUsed <= 5) return 5  // 5秒内额外5分
      if (timeUsed <= 10) return 3 // 10秒内额外3分
      if (timeUsed <= 15) return 1 // 15秒内额外1分
      return 0 // 15秒后无奖励
    },

    nextPlayer() {
      this.currentPlayerIndex = (this.currentPlayerIndex + 1) % this.playerCount
      this.startNewRound()
    },

    nextRound() {
      this.currentRound++
      this.currentPlayerIndex = 0
      this.startNewRound()
    },

    showMessage(text, type) {
      this.message = text
      this.messageType = type
    },

    endGame() {
      clearInterval(this.timer)
      this.gameState = 'finished'
    },

    resetGame() {
      this.gameState = 'setup'
      this.currentRound = 1
      this.currentPlayerIndex = 0
      this.playerScores = [0, 0, 0, 0, 0, 0]
      this.playerStats = [
        { attempts: 0, correct: 0 },
        { attempts: 0, correct: 0 },
        { attempts: 0, correct: 0 },
        { attempts: 0, correct: 0 },
        { attempts: 0, correct: 0 },
        { attempts: 0, correct: 0 }
      ]
      this.remainingCards = []
      this.currentCards = []
      this.fastestTime = null
      this.message = ''
      clearInterval(this.timer)
    },

    backToSetup() {
      this.resetGame()
    }
  },

  beforeUnmount() {
    if (this.timer) {
      clearInterval(this.timer)
    }
  }
}
</script>

<style scoped>
.game-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  font-family: 'Arial', sans-serif;
  padding: 20px;
}

/* 设置界面样式 */
.setup-screen {
  max-width: 600px;
  margin: 0 auto;
  background: rgba(255, 255, 255, 0.95);
  border-radius: 20px;
  padding: 30px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
}

.setup-header {
  text-align: center;
  margin-bottom: 40px;
}

.game-title {
  font-size: 2.5rem;
  color: #4a5568;
  margin-bottom: 10px;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1);
}

.game-subtitle {
  font-size: 1.2rem;
  color: #718096;
}

.game-rules {
  background: rgba(255, 255, 255, 0.9);
  border-radius: 15px;
  padding: 20px;
  margin-bottom: 30px;
  border: 2px solid #e2e8f0;
}

.game-rules h3 {
  color: #4a5568;
  margin-bottom: 15px;
  font-size: 1.3rem;
  text-align: center;
}

.rules-content {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.rule-item {
  display: flex;
  align-items: center;
  gap: 12px;
  background: #f7fafc;
  padding: 12px 15px;
  border-radius: 10px;
  border: 1px solid #e2e8f0;
}

.rule-icon {
  font-size: 1.2rem;
  min-width: 30px;
}

.rule-item span:last-child {
  color: #4a5568;
  font-size: 0.95rem;
  line-height: 1.4;
}

.player-setup {
  display: flex;
  flex-direction: column;
  gap: 30px;
}

.player-count-selector h3,
.player-names h3 {
  color: #4a5568;
  margin-bottom: 15px;
  font-size: 1.3rem;
}

.count-buttons {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.count-btn {
  padding: 12px 20px;
  border: 3px solid #e2e8f0;
  background: white;
  border-radius: 15px;
  font-size: 1rem;
  font-weight: bold;
  color: #4a5568;
  cursor: pointer;
  transition: all 0.3s ease;
}

.count-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.count-btn.active {
  background: #48bb78;
  color: white;
  border-color: #48bb78;
}

.name-inputs {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 15px;
}

.player-input-group {
  display: flex;
  align-items: center;
  gap: 10px;
  background: #f7fafc;
  padding: 15px;
  border-radius: 15px;
  border: 2px solid #e2e8f0;
}

.player-avatar {
  font-size: 1.5rem;
}

.name-input {
  flex: 1;
  padding: 8px 12px;
  border: 2px solid #e2e8f0;
  border-radius: 10px;
  font-size: 1rem;
  outline: none;
}

.name-input:focus {
  border-color: #48bb78;
}

.start-game-btn {
  padding: 18px 40px;
  background: linear-gradient(45deg, #48bb78, #38a169);
  color: white;
  border: none;
  border-radius: 25px;
  font-size: 1.2rem;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(72, 187, 120, 0.3);
}

.start-game-btn:hover:not(:disabled) {
  transform: translateY(-3px);
  box-shadow: 0 8px 25px rgba(72, 187, 120, 0.4);
}

.start-game-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* 游戏界面样式 */
.game-screen {
  max-width: 800px;
  margin: 0 auto;
  background: rgba(255, 255, 255, 0.95);
  border-radius: 20px;
  padding: 25px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
}

.game-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 2px solid #e2e8f0;
}

.round-info {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.round-number {
  font-size: 1.3rem;
  font-weight: bold;
  color: #4a5568;
}

.cards-left {
  font-size: 0.9rem;
  color: #718096;
}

.timer-container {
  display: flex;
  align-items: center;
}

.timer {
  display: flex;
  align-items: center;
  gap: 8px;
  background: #48bb78;
  color: white;
  padding: 12px 20px;
  border-radius: 25px;
  font-size: 1.2rem;
  font-weight: bold;
  box-shadow: 0 4px 15px rgba(72, 187, 120, 0.3);
}

.timer.time-warning {
  background: #ed8936;
  animation: pulse 1s infinite;
}

@keyframes pulse {
  0% { transform: scale(1); }
  50% { transform: scale(1.05); }
  100% { transform: scale(1); }
}

.end-game-btn {
  padding: 10px 20px;
  background: #e53e3e;
  color: white;
  border: none;
  border-radius: 15px;
  font-size: 0.9rem;
  cursor: pointer;
  transition: all 0.3s ease;
}

.end-game-btn:hover {
  background: #c53030;
  transform: translateY(-1px);
}

.game-main {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 30px;
  margin-bottom: 30px;
}

.cards-display {
  display: flex;
  gap: 20px;
  justify-content: center;
  flex-wrap: wrap;
}

.card {
  width: 80px;
  height: 120px;
  background: linear-gradient(145deg, #ffffff, #f7fafc);
  border-radius: 15px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
  border: 3px solid #e2e8f0;
  transition: all 0.3s ease;
  position: relative;
  padding: 8px;
}

.card:hover {
  transform: translateY(-5px);
  box-shadow: 0 12px 35px rgba(0, 0, 0, 0.2);
}

.card-number {
  font-size: 2.5rem;
  font-weight: bold;
  color: #4a5568;
  margin-bottom: 5px;
}

.card-suit {
  font-size: 1.2rem;
  position: absolute;
  bottom: 8px;
  right: 8px;
}

.current-player {
  text-align: center;
}

.player-info {
  display: flex;
  align-items: center;
  gap: 15px;
  background: linear-gradient(45deg, #667eea, #764ba2);
  color: white;
  padding: 15px 25px;
  border-radius: 20px;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.player-avatar {
  font-size: 1.8rem;
}

.player-name {
  font-size: 1.3rem;
  font-weight: bold;
}

.turn-indicator {
  font-size: 0.9rem;
  opacity: 0.9;
}

.answer-input {
  display: flex;
  gap: 15px;
  align-items: center;
  background: #f7fafc;
  padding: 20px;
  border-radius: 15px;
  border: 2px solid #e2e8f0;
}

.expression-input {
  flex: 1;
  padding: 15px 20px;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  font-size: 1.1rem;
  outline: none;
  transition: all 0.3s ease;
}

.expression-input:focus {
  border-color: #48bb78;
  box-shadow: 0 0 0 3px rgba(72, 187, 120, 0.1);
}

.submit-btn {
  padding: 15px 30px;
  background: linear-gradient(45deg, #48bb78, #38a169);
  color: white;
  border: none;
  border-radius: 12px;
  font-size: 1rem;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(72, 187, 120, 0.3);
}

.submit-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(72, 187, 120, 0.4);
}

.submit-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.message {
  padding: 15px 25px;
  border-radius: 15px;
  font-size: 1.1rem;
  font-weight: bold;
  text-align: center;
  min-width: 300px;
}

.message.success {
  background: linear-gradient(45deg, #48bb78, #38a169);
  color: white;
}

.message.error {
  background: linear-gradient(45deg, #ed8936, #dd6b20);
  color: white;
}

/* 计分板样式 */
.scoreboard {
  background: #f7fafc;
  border-radius: 15px;
  padding: 20px;
  border: 2px solid #e2e8f0;
}

.score-header {
  text-align: center;
  font-size: 1.2rem;
  font-weight: bold;
  color: #4a5568;
  margin-bottom: 15px;
}

.score-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.score-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 15px;
  background: white;
  border-radius: 10px;
  border: 2px solid #e2e8f0;
  transition: all 0.3s ease;
}

.score-item.current-turn {
  border-color: #48bb78;
  background: linear-gradient(45deg, rgba(72, 187, 120, 0.1), rgba(56, 161, 105, 0.1));
  transform: scale(1.02);
}

.player-score-info {
  display: flex;
  align-items: center;
  gap: 10px;
}

.player-avatar-small {
  font-size: 1.2rem;
}

.player-name-small {
  font-weight: bold;
  color: #4a5568;
}

.score {
  font-size: 1.2rem;
  font-weight: bold;
  color: #48bb78;
}

/* 结束界面样式 */
.finished-screen {
  max-width: 600px;
  margin: 0 auto;
  background: rgba(255, 255, 255, 0.95);
  border-radius: 20px;
  padding: 30px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  text-align: center;
}

.finished-header h2 {
  font-size: 2rem;
  color: #4a5568;
  margin-bottom: 10px;
}

.finished-header p {
  font-size: 1.1rem;
  color: #718096;
  margin-bottom: 30px;
}

.final-leaderboard {
  margin-bottom: 30px;
}

.leaderboard-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 15px 20px;
  margin-bottom: 10px;
  background: white;
  border-radius: 15px;
  border: 2px solid #e2e8f0;
  transition: all 0.3s ease;
}

.leaderboard-item.rank-1 {
  background: linear-gradient(45deg, #ffd700, #ffb347);
  border-color: #ffd700;
  color: #4a5568;
}

.leaderboard-item.rank-2 {
  background: linear-gradient(45deg, #c0c0c0, #a8a8a8);
  border-color: #c0c0c0;
  color: #4a5568;
}

.leaderboard-item.rank-3 {
  background: linear-gradient(45deg, #cd7f32, #a0522d);
  border-color: #cd7f32;
  color: white;
}

.leaderboard-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.rank-badge {
  font-size: 1.5rem;
  font-weight: bold;
  min-width: 40px;
}

.player-info {
  display: flex;
  align-items: center;
  gap: 15px;
  flex: 1;
}

.final-score {
  font-size: 1.2rem;
  font-weight: bold;
  color: #4a5568;
  margin-bottom: 8px;
}

.player-stats {
  display: flex;
  flex-direction: column;
  gap: 4px;
  font-size: 0.85rem;
}

.stat-mini {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.stat-label {
  color: #718096;
}

.stat-value {
  color: #4a5568;
  font-weight: bold;
}

.game-stats {
  display: flex;
  justify-content: center;
  gap: 30px;
  margin-bottom: 30px;
  padding: 20px;
  background: #f7fafc;
  border-radius: 15px;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 5px;
}

.stat-label {
  font-size: 0.9rem;
  color: #718096;
}

.stat-value {
  font-size: 1.2rem;
  font-weight: bold;
  color: #4a5568;
}

.finished-actions {
  display: flex;
  gap: 15px;
  justify-content: center;
}

.play-again-btn,
.back-to-setup-btn {
  padding: 15px 30px;
  border: none;
  border-radius: 15px;
  font-size: 1rem;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
}

.play-again-btn {
  background: linear-gradient(45deg, #48bb78, #38a169);
  color: white;
  box-shadow: 0 4px 15px rgba(72, 187, 120, 0.3);
}

.play-again-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(72, 187, 120, 0.4);
}

.back-to-setup-btn {
  background: linear-gradient(45deg, #718096, #4a5568);
  color: white;
  box-shadow: 0 4px 15px rgba(113, 128, 150, 0.3);
}

.back-to-setup-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(113, 128, 150, 0.4);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .game-container {
    padding: 10px;
  }

  .setup-screen,
  .game-screen,
  .finished-screen {
    padding: 20px;
  }

  .game-title {
    font-size: 2rem;
  }

  .cards-display {
    gap: 10px;
  }

  .card {
    width: 60px;
    height: 90px;
  }

  .card-number {
    font-size: 2rem;
  }

  .card-suit {
    font-size: 1rem;
  }

  .answer-input {
    flex-direction: column;
    gap: 10px;
  }

  .expression-input {
    width: 100%;
  }

  .game-stats {
    flex-direction: column;
    gap: 15px;
  }

  .finished-actions {
    flex-direction: column;
  }
}
</style>
