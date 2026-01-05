<template>
  <div class="cow-horse-clock">
    <div class="container">
      <!-- 标题区域 -->
      <header class="header">
        <h1 class="title">🐂🐎 牛马时钟</h1>
        <p class="subtitle">计算你还有多久可以退休，下班倒计时</p>
      </header>

      <!-- 设置区域 -->
      <div class="settings">
        <div class="setting-group">
          <label class="setting-label">
            <span class="icon">🏖️</span>
            计划退休日期
          </label>
          <input
            type="date"
            v-model="retirementDate"
            class="date-input"
            @change="saveSettings"
          />
        </div>

        <div class="setting-group">
          <label class="setting-label">
            <span class="icon">🌅</span>
            每天上班时间
          </label>
          <input
            type="time"
            v-model="workStartTime"
            class="time-input"
            @change="saveSettings"
          />
        </div>

        <div class="setting-group">
          <label class="setting-label">
            <span class="icon">🏠</span>
            每天下班时间
          </label>
          <input
            type="time"
            v-model="workEndTime"
            class="time-input"
            @change="saveSettings"
          />
        </div>
      </div>

      <!-- 倒计时显示区域 -->
      <div class="countdown-section">
        <!-- 距离退休倒计时 -->
        <div class="countdown-card retirement-card">
          <div class="card-header">
            <span class="card-icon">🏖️</span>
            <h3 class="card-title">距离退休</h3>
          </div>
          <div class="countdown-display">
            <div class="time-unit">
              <div class="time-value">{{ retirementCountdown.days }}</div>
              <div class="time-label">天</div>
            </div>
            <div class="time-unit">
              <div class="time-value">{{ retirementCountdown.hours }}</div>
              <div class="time-label">时</div>
            </div>
            <div class="time-unit">
              <div class="time-value">{{ retirementCountdown.minutes }}</div>
              <div class="time-label">分</div>
            </div>
            <div class="time-unit">
              <div class="time-value">{{ retirementCountdown.seconds }}</div>
              <div class="time-label">秒</div>
            </div>
          </div>
          <div class="progress-bar">
            <div
              class="progress-fill"
              :style="{ width: retirementProgress + '%' }"
            ></div>
          </div>
        </div>

        <!-- 距离下班倒计时 -->
        <div class="countdown-card offwork-card" v-if="isWorkingDay">
          <div class="card-header">
            <span class="card-icon">🏠</span>
            <h3 class="card-title">距离下班</h3>
          </div>
          <div class="countdown-display">
            <div class="time-unit">
              <div class="time-value">{{ offworkCountdown.hours }}</div>
              <div class="time-label">时</div>
            </div>
            <div class="time-unit">
              <div class="time-value">{{ offworkCountdown.minutes }}</div>
              <div class="time-label">分</div>
            </div>
            <div class="time-unit">
              <div class="time-value">{{ offworkCountdown.seconds }}</div>
              <div class="time-label">秒</div>
            </div>
          </div>
          <div class="progress-bar">
            <div
              class="progress-fill offwork-fill"
              :style="{ width: offworkProgress + '%' }"
            ></div>
          </div>
        </div>

        <!-- 非工作时间显示 -->
        <div class="countdown-card rest-card" v-else>
          <div class="card-header">
            <span class="card-icon">😴</span>
            <h3 class="card-title">休息时间</h3>
          </div>
          <div class="rest-message">
            <p>现在是休息时间，享受生活吧！</p>
            <p class="next-work-time">下次上班时间：{{ nextWorkTime }}</p>
          </div>
        </div>
      </div>

      <!-- 激励语区域 -->
      <div class="motivation-section">
        <div class="motivation-card">
          <p class="motivation-text">{{ currentMotivation }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CowHorseClock',
  data() {
    return {
      retirementDate: '',
      workStartTime: '09:00',
      workEndTime: '18:00',
      retirementCountdown: {
        days: 0,
        hours: 0,
        minutes: 0,
        seconds: 0
      },
      offworkCountdown: {
        hours: 0,
        minutes: 0,
        seconds: 0
      },
      retirementProgress: 0,
      offworkProgress: 0,
      isWorkingDay: false,
      nextWorkTime: '',
      timer: null,
      motivations: [
        "坚持就是胜利，距离自由越来越近了！",
        "每一天都是新的开始，加油！",
        "时间在流逝，梦想在靠近！",
        "不要放弃，今天的努力就是明天的自由！",
        "人生苦短，及时行乐，但也要努力工作！",
        "距离退休还有{{days}}天，继续加油！",
        "下班时间快到了，坚持住！",
        "生活不止眼前的苟且，还有诗和远方！",
        "努力工作，享受生活，两者兼得！",
        "时间是最宝贵的财富，好好珍惜！"
      ]
    }
  },
  computed: {
    currentMotivation() {
      if (!this.retirementDate) return "请先设置你的退休日期，让我们一起倒计时吧！"

      const days = this.retirementCountdown.days
      let motivation = this.motivations[Math.floor(Math.random() * (this.motivations.length - 1))]

      if (days < 365) {
        motivation = `距离退休只有${days}天了，胜利在望！`
      } else if (days < 365 * 2) {
        motivation = `还有${Math.floor(days / 30)}个月，加油！`
      } else {
        motivation = `距离退休还有${Math.floor(days / 365)}年，继续努力！`
      }

      return motivation
    }
  },
  mounted() {
    this.loadSettings()
    this.startTimer()
  },
  beforeUnmount() {
    if (this.timer) {
      clearInterval(this.timer)
    }
  },
  methods: {
    loadSettings() {
      const settings = localStorage.getItem('cowHorseClock')
      if (settings) {
        const data = JSON.parse(settings)
        this.retirementDate = data.retirementDate || ''
        this.workStartTime = data.workStartTime || '09:00'
        this.workEndTime = data.workEndTime || '18:00'
      }
    },
    saveSettings() {
      const settings = {
        retirementDate: this.retirementDate,
        workStartTime: this.workStartTime,
        workEndTime: this.workEndTime
      }
      localStorage.setItem('cowHorseClock', JSON.stringify(settings))
      this.updateCountdowns()
    },
    startTimer() {
      this.updateCountdowns()
      this.timer = setInterval(() => {
        this.updateCountdowns()
      }, 1000)
    },
    updateCountdowns() {
      this.updateRetirementCountdown()
      this.updateOffworkCountdown()
    },
    updateRetirementCountdown() {
      if (!this.retirementDate) return

      const now = new Date()
      const retirement = new Date(this.retirementDate + 'T23:59:59')
      const diff = retirement - now

      if (diff > 0) {
        const days = Math.floor(diff / (1000 * 60 * 60 * 24))
        const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
        const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
        const seconds = Math.floor((diff % (1000 * 60)) / 1000)

        this.retirementCountdown = { days, hours, minutes, seconds }

        // 计算进度（假设从25岁工作到退休，60岁退休）
        const totalWorkDays = 60 * 365
        const workedDays = totalWorkDays - days
        this.retirementProgress = Math.min((workedDays / totalWorkDays) * 100, 100)
      } else {
        this.retirementCountdown = { days: 0, hours: 0, minutes: 0, seconds: 0 }
        this.retirementProgress = 100
      }
    },
    updateOffworkCountdown() {
      const now = new Date()
      const currentTime = now.getHours() * 60 + now.getMinutes()
      const workStart = this.parseTime(this.workStartTime)
      const workEnd = this.parseTime(this.workEndTime)

      if (currentTime >= workStart && currentTime < workEnd) {
        // 工作时间内
        this.isWorkingDay = true
        const endTime = new Date()
        const [endHour, endMinute] = this.workEndTime.split(':').map(Number)
        endTime.setHours(endHour, endMinute, 0, 0)

        const diff = endTime - now
        if (diff > 0) {
          const hours = Math.floor(diff / (1000 * 60 * 60))
          const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
          const seconds = Math.floor((diff % (1000 * 60)) / 1000)
          this.offworkCountdown = { hours, minutes, seconds }

          // 计算下班进度
          const totalWorkMinutes = (workEnd - workStart)
          const workedMinutes = (currentTime - workStart)
          this.offworkProgress = Math.min((workedMinutes / totalWorkMinutes) * 100, 100)
        } else {
          this.offworkCountdown = { hours: 0, minutes: 0, seconds: 0 }
          this.offworkProgress = 100
        }
      } else {
        // 非工作时间
        this.isWorkingDay = false
        this.calculateNextWorkTime()
      }
    },
    parseTime(timeString) {
      const [hours, minutes] = timeString.split(':').map(Number)
      return hours * 60 + minutes
    },
    calculateNextWorkTime() {
      const now = new Date()
      const tomorrow = new Date(now)
      tomorrow.setDate(tomorrow.getDate() + 1)
      tomorrow.setHours(...this.workStartTime.split(':').map(Number), 0, 0)

      this.nextWorkTime = tomorrow.toLocaleString('zh-CN', {
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      })
    }
  }
}
</script>

<style scoped>
.cow-horse-clock {
  width: 100%;
  min-height: 100vh;
  padding: 20px;
}

.container {
  max-width: 800px;
  margin: 0 auto;
  background: rgba(255, 255, 255, 0.95);
  border-radius: 20px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  backdrop-filter: blur(10px);
}

.header {
  text-align: center;
  padding: 40px 20px 20px;
  background: linear-gradient(135deg, #ff6b6b, #ffa500);
  color: white;
}

.title {
  font-size: 3rem;
  font-weight: bold;
  margin-bottom: 10px;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
}

.subtitle {
  font-size: 1.2rem;
  opacity: 0.9;
}

.settings {
  padding: 30px;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
}

.setting-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.setting-label {
  font-weight: bold;
  color: #333;
  display: flex;
  align-items: center;
  gap: 8px;
}

.icon {
  font-size: 1.2rem;
}

.date-input,
.time-input {
  padding: 12px 16px;
  border: 2px solid #e1e5e9;
  border-radius: 10px;
  font-size: 1rem;
  transition: all 0.3s ease;
}

.date-input:focus,
.time-input:focus {
  outline: none;
  border-color: #ff6b6b;
  box-shadow: 0 0 0 3px rgba(255, 107, 107, 0.1);
}

.countdown-section {
  padding: 30px;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
}

.countdown-card {
  background: white;
  border-radius: 15px;
  padding: 25px;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
  border: 2px solid transparent;
  transition: all 0.3s ease;
}

.retirement-card {
  border-color: #ff6b6b;
  background: linear-gradient(135deg, #fff5f5, #ffeaea);
}

.offwork-card {
  border-color: #ffa500;
  background: linear-gradient(135deg, #fff9e6, #fff3cd);
}

.rest-card {
  border-color: #4ecdc4;
  background: linear-gradient(135deg, #f0fffe, #e6fffa);
}

.card-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 20px;
}

.card-icon {
  font-size: 2rem;
}

.card-title {
  font-size: 1.5rem;
  font-weight: bold;
  color: #333;
}

.countdown-display {
  display: flex;
  justify-content: space-around;
  margin-bottom: 20px;
}

.time-unit {
  text-align: center;
  min-width: 60px;
}

.time-value {
  font-size: 2.5rem;
  font-weight: bold;
  color: #333;
  line-height: 1;
}

.time-label {
  font-size: 0.9rem;
  color: #666;
  margin-top: 5px;
}

.progress-bar {
  height: 8px;
  background: rgba(0, 0, 0, 0.1);
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #ff6b6b, #ffa500);
  border-radius: 4px;
  transition: width 0.5s ease;
}

.offwork-fill {
  background: linear-gradient(90deg, #ffa500, #ff6b6b);
}

.rest-message {
  text-align: center;
  color: #666;
  line-height: 1.6;
}

.next-work-time {
  font-weight: bold;
  color: #4ecdc4;
  margin-top: 10px;
}

.motivation-section {
  padding: 20px 30px 30px;
}

.motivation-card {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  padding: 20px;
  border-radius: 15px;
  text-align: center;
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
}

.motivation-text {
  font-size: 1.2rem;
  font-weight: 500;
  line-height: 1.6;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .title {
    font-size: 2.5rem;
  }

  .settings {
    grid-template-columns: 1fr;
    padding: 20px;
  }

  .countdown-section {
    grid-template-columns: 1fr;
    padding: 20px;
  }

  .countdown-display {
    flex-wrap: wrap;
    gap: 15px;
  }

  .time-unit {
    min-width: 50px;
  }

  .time-value {
    font-size: 2rem;
  }
}
</style>
