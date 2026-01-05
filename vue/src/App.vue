<template>
  <div id="app">
    <TwentyFourGame />
  </div>
</template>

<script>
import TwentyFourGame from './components/TwentyFourGame.vue'

export default {
  name: 'App',
  components: {
    TwentyFourGame
  }
}
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Arial', sans-serif;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
}

#app {
  width: 100%;
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
