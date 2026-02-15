<script setup>
import { computed, onMounted, ref } from 'vue'
import PhotoCard from './components/PhotoCard.vue'

// Счёт дней
const together = ref('0 дн 0 ч 0 м 0 с')
const startDate = new Date('2025-02-16T03:07:45')

const updateTimer = () => {
  const now = new Date()
  let diff = now - startDate
  
  const days = Math.floor(diff / (1000 * 60 * 60 * 24))
  diff %= (1000 * 60 * 60 * 24)
  const hours = Math.floor(diff / (1000 * 60 * 60))
  diff %= (1000 * 60 * 60)
  const minutes = Math.floor(diff / (1000 * 60))
  diff %= (1000 * 60)
  const seconds = Math.floor(diff / 1000)
  
  together.value = `${days}д ${String(hours).padStart(2, '0')}ч ${String(minutes).padStart(2, '0')}м ${String(seconds).padStart(2, '0')}с`
}

onMounted(() => {
  updateTimer()
  setInterval(updateTimer, 1000)
})

// Фотки из src/assets: "1 normal.jpg" — обычное, "1 loveised.png" — при нажатии (фантик)
const assetModules = import.meta.glob('/src/assets/**/*.{png,jpg,jpeg,PNG,JPG,JPEG}', {
  eager: true,
  query: '?url',
  import: 'default'
})

const normalByNum = {}
const loveByNum = {}
const containByNum = {}

for (const [path, mod] of Object.entries(assetModules)) {
  const url = typeof mod === 'string' ? mod : mod?.default
  if (!url) continue
  const rawName = path.replace(/^.*[\\/]/, '')
  const name = decodeURIComponent(rawName)
  const matchNormal = name.match(/^(\d+)[\s-]+normal(-h)?\.(png|jpg|jpeg)$/i)
  const matchLoveised = name.match(/^(\d+)[\s-]+loveised(-h)?\.(png|jpg|jpeg)$/i)
  if (matchNormal) {
    normalByNum[matchNormal[1]] = url
    if (matchNormal[2]) containByNum[matchNormal[1]] = true
  }
  if (matchLoveised) {
    loveByNum[matchLoveised[1]] = url
    if (matchLoveised[2]) containByNum[matchLoveised[1]] = true
  }
}

const photoPairs = Object.keys(normalByNum)
  .sort((a, b) => Number(a) - Number(b))
  .filter((num) => loveByNum[num])
  .map((num) => ({
    normal: normalByNum[num],
    love: loveByNum[num],
    contain: Boolean(containByNum[num])
  }))

// Ищем бонус фото (bonus-loveised.png)
const bonusPhoto = Object.values(assetModules).find((mod) => {
  const url = typeof mod === 'string' ? mod : mod?.default
  return url && url.includes('bonus')
})

const quotes = [
  'Жарили шашлыки ходили с друзьями',
  'ругались но главное сфоткались',
  'Катались слушали музыку и просто были рядом',
  'Самое классное как мы покупались',
  'Дома у Бере такая стеснительная была',
  'Видно как ты от меня тащишься',
  'Такой удивленный взгляд когда я тебя поцеловал',
  'Тогда тебе не айсед фраппучино принесли',
  'Нужно было со всеми родственниками познакомить да?)',
  '(Описание к фотке с бургером кстати)',
  'Иван Дорн слушали и ссорились тоже)',
  'Ты мне такто на яхте обещала прокатить',
  'И то самое зеркало',
  'Тогда еще Ару говорила остаться у нее',
  'Правда милая но ты забулила фотку',
  'В итоге он у меня в посте',
  'Тоже так то в посте',
  'Это жесть',
  'Нет',
  'Менин бетиме жауысыппа?',
  'Мы тут такие рассфокусированные',
]

const photoTitles = [
  'Как мы купались в лучах заката',
  'Алматы музей Искусств',
  'Твое любимое пассажирское место',
  'Когда ты говорила что мы тонем',
  'Первая встреча как сошлись',
  'Как мы почти каждый день приходили в Карак',
  'Самая смешная лайв фотка',
  'Как мы пили чай в Турции а ты теплое молоко',
  'Совместный семейное посиделка',
  'Здесь мы ели Бургер Кинг',
  'Первый совместный "Пикник"',
  'Твоя любимая станция Метро',
  'Дома в Турции',
  'Как ты в Астане решила украсть худи',
  'Милая фотка Дома',
  'Говорила так не сфоткаешься',
  'Лучшая наша фотка',
  'Как мы дурачились и устроили хэппи хаус Аделине',
  'Тут ты думала что мне пофек',
  'Принес мак для фотобуки)',
  'Фото как мы прощались в Турции'
]

const heartBalloons = Array.from({ length: 18 }, (_, index) => index)

const screen = ref('letter') // letter | book | end
const isUnlocked = ref(false)
const isDragging = ref(false)
const loveValue = ref(12)
const scaleRef = ref(null)
const isOverLimit = computed(() => loveValue.value > 100)

const isMusicOn = ref(false)

const currentIndex = ref(0)
const pageDirection = ref('page-next')
const currentPair = computed(() => photoPairs[currentIndex.value] || null)

let pageAudio
let bgAudio

onMounted(() => {
  pageAudio = new Audio('/sounds/page.mp3')
  pageAudio.volume = 0.5
  bgAudio = new Audio('/sounds/background.mp3')
  bgAudio.loop = true
  bgAudio.volume = 0.35
})

function playSound(audio) {
  if (!audio) return
  audio.currentTime = 0
  audio.play().catch(() => {})
}

function playPage() {
  playSound(pageAudio)
}

function toggleMusic() {
  if (!bgAudio) return
  if (isMusicOn.value) {
    bgAudio.pause()
    isMusicOn.value = false
    return
  }

  bgAudio.currentTime = 0
  bgAudio.play().then(() => {
    isMusicOn.value = true
  }).catch(() => {
    isMusicOn.value = false
  })
}

const lovePercent = computed(() => Math.min(loveValue.value, 140) / 140 * 100)
const loveLabel = computed(() => (loveValue.value > 100 ? 'Больше максимума' : `${Math.round(loveValue.value)}%`))

function startDrag(event) {
  if (event.button !== undefined && event.button !== 0) return
  if (isUnlocked.value) return
  isDragging.value = true
  const el = scaleRef.value
  if (el?.setPointerCapture) el.setPointerCapture(event.pointerId)
  updateDrag(event)
}

function updateDrag(event) {
  if (!isDragging.value) return
  const el = scaleRef.value
  if (!el) return
  const rect = el.getBoundingClientRect()
  const raw = (event.clientX - rect.left) / rect.width
  const value = Math.min(Math.max(raw, 0), 1) * 140
  loveValue.value = value
  if (value >= 120 && !isUnlocked.value) {
    isUnlocked.value = true
    playMagic()
  }
}

function endDrag() {
  if (!isDragging.value) return
  isDragging.value = false
}

function prevPhoto() {
  if (currentIndex.value <= 0) return
  pageDirection.value = 'page-prev'
  currentIndex.value -= 1
  playPage()
}

function nextPhoto() {
  if (currentIndex.value >= photoPairs.length - 1) {
    screen.value = 'end'
  } else {
    pageDirection.value = 'page-next'
    currentIndex.value += 1
  }
  playPage()
}

function startBook() {
  screen.value = 'book'
}

function goToLetter() {
  screen.value = 'letter'
  isUnlocked.value = false
  currentIndex.value = 0
  loveValue.value = 12
  pageDirection.value = 'page-next'
}
</script>

<template>
  <div class="page" :class="{ unlocked: isUnlocked }">
    <div class="bg-stars"></div>
    <div class="bg-hearts" aria-hidden="true">
      <span
        v-for="index in heartBalloons"
        :key="index"
        class="heart-balloon"
        :style="{
          '--delay': `${index * 0.7}s`,
          '--x': `${(index * 5) % 100}%`,
          '--size': `${12 + (index % 6) * 4}px`,
          '--duration': `${8 + (index % 4) * 1.5}s`
        }"
      ></span>
    </div>
    
    <header class="header">
      <h1 class="title">Наша волшебная книга</h1>
      <p class="subtitle">Приятного тебе просмотра с праздником любимая ✨</p>
      <button
        class="music-toggle"
        type="button"
        :aria-pressed="isMusicOn"
        @click="toggleMusic"
      >
        Музыка: {{ isMusicOn ? 'вкл' : 'выкл' }}
      </button>
    </header>

    <main class="gallery">
      <section v-if="!isUnlocked" class="cover">
        <div class="cover-book" :class="{ 'over-limit': isOverLimit }">
          <div class="cover-shine"></div>
          <div class="sparkles"></div>
          <div class="cover-text">
            <span class="cover-kicker">Книга чувств</span>
            <h2 class="cover-title">Насколько ты меня любишь?</h2>
            <p class="cover-sub">Потяни шкалу вправо и превзойди лимит</p>
          </div>
          <div
            ref="scaleRef"
            class="love-scale"
            :class="{ dragging: isDragging, 'over-limit': isOverLimit }"
            @pointerdown="startDrag"
            @pointermove="updateDrag"
            @pointerup="endDrag"
            @pointercancel="endDrag"
            @pointerleave="endDrag"
          >
            <div class="love-track"></div>
            <div class="love-fill" :style="{ width: `${lovePercent}%` }"></div>
            <div class="love-limit"></div>
            <div class="love-knob" :style="{ left: `${lovePercent}%` }"></div>
          </div>
          <div class="love-label">
            <span>{{ loveLabel }}</span>
            <span class="love-hint">Перетяни за лимит, чтобы открыть</span>
          </div>
        </div>
      </section>

      <section v-else-if="screen === 'letter'" class="letter-screen">
        <div class="letter">
          <h2 class="letter-title">💌</h2>
          <p class="letter-text">Привет, моя любовь,</p>
          <p class="letter-text">Эта книга — мой способ рассказать тебе то, что слова не могут передать. Каждое фото здесь — наша история, каждый момент — которым я дорожу.</p>
          <p class="letter-text">Спасибо что ты есть, спасибо за каждый день рядом с тобой.</p>
          <p class="letter-text">Ты навсегда в моем сердце<3</p>
          <button class="letter-btn" @click="startBook">Открыть книгу</button>
        </div>
      </section>

      <section v-else-if="screen === 'book'" class="story">
        <div class="story-bookmark"></div>
        <div class="sparkles story-sparkles"></div>
        <div class="story-header">
          <p>Нажми на фото, чтобы превратить его в обертку Love is</p>
        </div>
        <div class="story-book">
          <transition :name="pageDirection" mode="out-in">
            <PhotoCard
              v-if="currentPair"
              :key="currentIndex"
              :normal-src="currentPair.normal"
              :love-src="currentPair.love"
              :alt="`Фото ${currentIndex + 1}`"
              :caption-top="photoTitles[currentIndex % photoTitles.length]"
              :quote="quotes[currentIndex % quotes.length]"
              :contain="currentPair.contain"
            />
          </transition>
        </div>
        <div v-if="photoPairs.length > 1" class="story-nav">
          <button class="nav-btn" @click="prevPhoto" :disabled="currentIndex === 0">Назад</button>
          <span class="nav-info">{{ currentIndex + 1 }} / {{ photoPairs.length }}</span>
          <button class="nav-btn" @click="nextPhoto">Вперед</button>
        </div>
        <p v-if="photoPairs.length === 0" class="hint-empty">
          Положи в <code>src/assets</code> пары: <strong>1-normal.jpg</strong>, <strong>1-loveised.png</strong> и т.д. (без пробелов в имени). Либо запусти <code>bash rename-assets.sh</code> в папке проекта.
        </p>
      </section>

      <section v-else-if="screen === 'end'" class="ending">
        <div class="ending-content">
          <h2 class="ending-title">Конец? Нет, это только начало 💕</h2>
          <p class="ending-sub">И вот мой бонусный сюрприз для тебя:</p>
          <img v-if="bonusPhoto" :src="bonusPhoto" alt="Bonus" class="ending-bonus" />
          <p class="ending-text">Я тебя люблю очень сильно и пусть нам не мешает ничего в жизни что бы любить друг друга.</p>
          <button class="ending-btn" @click="goToLetter">Начать сначала</button>
        </div>
      </section>
    </main>

    <footer class="footer">
      <span>С любовью</span>
      <div class="days-together">
        <span class="days-icon">💕</span>
        <span>Мы уже вместе {{ together }} </span>
      </div>
    </footer>
  </div>
</template>

<style>
*,
*::before,
*::after {
  box-sizing: border-box;
}

html {
  margin: 0;
  padding: 0;
  background: linear-gradient(160deg, #fff5f7 0%, #ffe8ef 30%, #ffd6e0 70%, #ffcce0 100%);
  background-attachment: fixed;
}

body {
  margin: 0;
  min-height: 100vh;
  font-family: 'Nunito', sans-serif;
  background: transparent;
  color: #5c374c;
}

#app {
  min-height: 100vh;
}
</style>

<style scoped>
.page {
  min-height: 100vh;
  padding: clamp(1rem, 4vw, 2.5rem);
  display: flex;
  flex-direction: column;
  align-items: center;
  animation: page-intro 0.9s ease both;
}

.header {
  text-align: center;
  margin-bottom: clamp(1.5rem, 5vw, 3rem);
  animation: header-float 1s ease 0.1s both;
}

.title {
  font-family: 'Cormorant Garamond', serif;
  font-size: clamp(2rem, 8vw, 3.5rem);
  font-weight: 600;
  margin: 0 0 0.5rem;
  color: #8b3a5c;
  text-shadow: 0 2px 20px rgba(139, 58, 92, 0.15);
}

.subtitle {
  font-size: clamp(0.9rem, 2.5vw, 1.1rem);
  margin: 0;
  opacity: 0.9;
}

.music-toggle {
  margin-top: 0.8rem;
  border: 1px solid rgba(139, 58, 92, 0.25);
  background: rgba(255, 255, 255, 0.7);
  color: #8b3a5c;
  padding: 0.35rem 0.8rem;
  border-radius: 999px;
  font-size: 0.8rem;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  box-shadow: 0 6px 14px rgba(139, 58, 92, 0.12);
}

.music-toggle:hover {
  transform: translateY(-1px);
  box-shadow: 0 10px 20px rgba(139, 58, 92, 0.18);
}

.gallery {
  display: grid;
  justify-items: center;
  max-width: 1100px;
  flex: 1;
}

.cover {
  width: 100%;
  display: grid;
  place-items: center;
}

.cover-book {
  position: relative;
  width: min(460px, 92vw);
  padding: clamp(1.6rem, 5vw, 2.5rem);
  border-radius: 24px;
  background:
    radial-gradient(circle at top left, rgba(255, 255, 255, 0.9), transparent 45%),
    linear-gradient(160deg, #a8486a 0%, #cf5b7f 45%, #f3a8b8 100%);
  color: #fff7fb;
  box-shadow:
    0 24px 60px rgba(138, 53, 84, 0.35),
    inset 0 0 0 1px rgba(255, 255, 255, 0.35);
  text-align: center;
  overflow: hidden;
}

.cover-book.over-limit {
  box-shadow:
    0 24px 70px rgba(255, 210, 230, 0.5),
    0 24px 60px rgba(138, 53, 84, 0.35),
    inset 0 0 0 1px rgba(255, 255, 255, 0.4);
}

.cover-shine {
  position: absolute;
  inset: -40% 40% auto -40%;
  height: 200%;
  background: radial-gradient(circle, rgba(255, 255, 255, 0.35), transparent 60%);
  transform: rotate(25deg);
  opacity: 0.6;
}

.sparkles {
  position: absolute;
  inset: -30% -10% -10% -10%;
  background-image:
    radial-gradient(circle, rgba(255, 255, 255, 0.7) 0 2px, transparent 3px),
    radial-gradient(circle, rgba(255, 255, 255, 0.5) 0 1px, transparent 3px),
    radial-gradient(circle, rgba(255, 255, 255, 0.6) 0 1.5px, transparent 3px);
  background-size: 140px 140px, 100px 100px, 180px 180px;
  background-position: 0 0, 40px 60px, 80px 20px;
  opacity: 0.45;
  animation: sparkle-float 8s linear infinite;
  pointer-events: none;
}

.cover-text {
  position: relative;
  z-index: 2;
}

.cover-kicker {
  letter-spacing: 0.25em;
  text-transform: uppercase;
  font-size: 0.65rem;
  opacity: 0.9;
}

.cover-title {
  margin: 0.6rem 0 0.4rem;
  font-family: 'Cormorant Garamond', serif;
  font-size: clamp(1.8rem, 5vw, 2.4rem);
  font-weight: 600;
}

.cover-sub {
  margin: 0 0 1.6rem;
  font-size: 0.95rem;
  opacity: 0.9;
}

.love-scale {
  position: relative;
  height: 18px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.2);
  margin: 0.2rem 0 0.8rem;
  cursor: grab;
  touch-action: pan-y;
}

.love-scale.dragging {
  cursor: grabbing;
}

.love-track {
  position: absolute;
  inset: 4px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.15);
}

.love-fill {
  position: absolute;
  top: 4px;
  left: 4px;
  height: 10px;
  border-radius: 999px;
  background: linear-gradient(90deg, #ffe3ec 0%, #ffd1e1 40%, #fff 100%);
  box-shadow: 0 0 15px rgba(255, 255, 255, 0.6);
}

.love-scale.over-limit .love-fill {
  animation: pulse-glow 1s ease-in-out infinite;
}

.love-limit {
  position: absolute;
  top: 3px;
  left: calc(100% - 4px);
  width: 2px;
  height: 12px;
  background: rgba(255, 255, 255, 0.65);
}

.love-knob {
  position: absolute;
  top: -6px;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background: #fff;
  transform: translateX(-50%);
  box-shadow: 0 10px 24px rgba(120, 44, 76, 0.3);
}

.love-scale.over-limit .love-knob {
  box-shadow: 0 0 20px rgba(255, 255, 255, 0.9), 0 12px 24px rgba(120, 44, 76, 0.35);
}

.love-label {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.9rem;
}

.love-hint {
  font-size: 0.75rem;
  opacity: 0.9;
}

.story {
  width: 100%;
  position: relative;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.story-bookmark {
  position: absolute;
  right: -12px;
  top: 20%;
  width: 28px;
  height: 160px;
  background: linear-gradient(135deg, #e8a8c8 0%, #f3a8b8 50%, #e8a8c8 100%);
  border-radius: 0 8px 8px 0;
  box-shadow: 2px 8px 20px rgba(139, 58, 92, 0.25);
  animation: ribbon-float 3s ease-in-out infinite;
}

@keyframes ribbon-float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(6px); }
}

.story-sparkles {
  inset: -10% -10% auto -10%;
  opacity: 0.25;
}

.letter-screen {
  display: grid;
  place-items: center;
  width: 100%;
}

.letter {
  width: min(440px, 92vw);
  padding: 2rem;
  border-radius: 20px;
  background:
    repeating-linear-gradient(
      90deg,
      transparent,
      transparent 2px,
      rgba(200, 150, 170, 0.05) 2px,
      rgba(200, 150, 170, 0.05) 4px
    ),
    linear-gradient(180deg, #fff9fb 0%, #fff 100%);
  box-shadow: 0 20px 60px rgba(139, 58, 92, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.8);
}

.letter-title {
  text-align: center;
  font-size: 3rem;
  margin: 0 0 1rem;
}

.letter-text {
  margin: 0.8rem 0;
  font-size: 1rem;
  line-height: 1.8;
  color: #5c374c;
  font-style: italic;
}

.letter-btn {
  display: block;
  margin: 1.5rem auto 0;
  padding: 0.7rem 1.8rem;
  border: none;
  background: linear-gradient(135deg, #8b3a5c, #cf5b7f);
  color: #fff;
  border-radius: 999px;
  font-weight: 600;
  cursor: pointer;
  box-shadow: 0 12px 30px rgba(139, 58, 92, 0.3);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.letter-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 16px 40px rgba(139, 58, 92, 0.4);
}

.ending {
  display: grid;
  place-items: center;
  width: 100%;
}

.ending-content {
  width: min(460px, 92vw);
  text-align: center;
  padding: 2rem;
  border-radius: 24px;
  background: linear-gradient(160deg, #fff5f7 0%, #ffe8ef 100%);
  box-shadow: 0 24px 60px rgba(139, 58, 92, 0.25);
}

.ending-title {
  margin: 0 0 1rem;
  font-family: 'Cormorant Garamond', serif;
  font-size: clamp(1.8rem, 5vw, 2.4rem);
  color: #8b3a5c;
}

.ending-sub {
  margin: 0 0 1.5rem;
  font-size: 0.95rem;
  color: #6d3f55;
}

.ending-bonus {
  width: 100%;
  max-width: 340px;
  aspect-ratio: 3/4;
  border-radius: 16px;
  object-fit: cover;
  margin: 0 auto 1.5rem;
  box-shadow: 0 12px 30px rgba(139, 58, 92, 0.2);
}

.ending-text {
  margin: 0 0 1.5rem;
  font-size: 0.95rem;
  color: #5c374c;
  line-height: 1.6;
}

.ending-btn {
  padding: 0.7rem 1.8rem;
  border: none;
  background: linear-gradient(135deg, #8b3a5c, #cf5b7f);
  color: #fff;
  border-radius: 999px;
  font-weight: 600;
  cursor: pointer;
  box-shadow: 0 12px 30px rgba(139, 58, 92, 0.3);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.ending-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 16px 40px rgba(139, 58, 92, 0.4);
}

.story-header {
  text-align: center;
}

.story-header p {
  margin: 0;
  font-size: 0.95rem;
  color: #6d3f55;
}

.story-book {
  display: grid;
  place-items: center;
  width: 100%;
}

.story-nav {
  display: inline-flex;
  align-items: center;
  gap: 1rem;
  justify-content: center;
}

.nav-btn {
  border: none;
  background: #fff;
  color: #8b3a5c;
  padding: 0.5rem 1rem;
  border-radius: 999px;
  font-weight: 600;
  cursor: pointer;
  box-shadow: 0 6px 16px rgba(139, 58, 92, 0.12);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.nav-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(139, 58, 92, 0.18);
}

.nav-btn:disabled {
  cursor: not-allowed;
  opacity: 0.5;
  box-shadow: none;
}

.nav-info {
  font-size: 0.9rem;
  color: #6d3f55;
}

.page-next-enter-active,
.page-next-leave-active,
.page-prev-enter-active,
.page-prev-leave-active {
  transition: transform 0.5s ease, opacity 0.5s ease;
}

.page-next-enter-from {
  opacity: 0;
  transform: translateX(40px) rotateY(-12deg);
}

.page-next-leave-to {
  opacity: 0;
  transform: translateX(-40px) rotateY(12deg);
}

.page-prev-enter-from {
  opacity: 0;
  transform: translateX(-40px) rotateY(12deg);
}

.page-prev-leave-to {
  opacity: 0;
  transform: translateX(40px) rotateY(-12deg);
}

@keyframes sparkle-float {
  0% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-12px);
  }
  100% {
    transform: translateY(0);
  }
}

@keyframes pulse-glow {
  0% {
    box-shadow: 0 0 12px rgba(255, 255, 255, 0.6);
  }
  50% {
    box-shadow: 0 0 22px rgba(255, 255, 255, 0.95);
  }
  100% {
    box-shadow: 0 0 12px rgba(255, 255, 255, 0.6);
  }
}

.hint-empty {
  grid-column: 1 / -1;
  text-align: center;
  max-width: 420px;
  margin: 0;
  padding: 1rem;
  font-size: 0.9rem;
  opacity: 0.85;
}

.hint-empty code {
  background: rgba(255, 255, 255, 0.7);
  padding: 0.2em 0.4em;
  border-radius: 4px;
}


.footer {
  margin-top: auto;
  padding: 1.5rem;
  font-size: 0.9rem;
  opacity: 0.8;
  font-style: italic;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
}

.bg-stars {
  position: fixed;
  inset: 0;
  pointer-events: none;
  background-image:
    radial-gradient(circle, rgba(255, 255, 255, 0.6) 0 1px, transparent 1px),
    radial-gradient(circle, rgba(255, 200, 220, 0.5) 0 1.5px, transparent 1.5px),
    radial-gradient(circle, rgba(255, 255, 255, 0.4) 0 1px, transparent 1px);
  background-size: 150px 150px, 200px 200px, 250px 250px;
  background-position: 0 0, 50px 50px, 100px 100px;
  animation: stars-float 20s linear infinite;
  z-index: -1;
}

.bg-hearts {
  position: fixed;
  inset: 0;
  pointer-events: none;
  overflow: hidden;
  z-index: -1;
}

.heart-balloon {
  position: absolute;
  bottom: -12vh;
  left: var(--x);
  width: var(--size);
  height: var(--size);
  background: #ff6fae;
  transform: rotate(-45deg);
  border-radius: 6px;
  animation: heart-float var(--duration) ease-in-out infinite;
  animation-delay: var(--delay);
  opacity: 0;
  filter: drop-shadow(0 6px 10px rgba(139, 58, 92, 0.18));
}

.heart-balloon::before {
  content: '';
  position: absolute;
  width: 100%;
  height: 100%;
  background: inherit;
  border-radius: 50%;
  top: -50%;
  left: 0;
  box-shadow: calc(var(--size) / 2) calc(var(--size) / 2) 0 0 #ff6fae;
}


@keyframes stars-float {
  0% {
    background-position: 0 0, 50px 50px, 100px 100px;
  }
  100% {
    background-position: 150px 150px, 250px 250px, 350px 350px;
  }
}

@keyframes page-intro {
  0% {
    opacity: 0;
    transform: translateY(14px);
  }
  100% {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes header-float {
  0% {
    opacity: 0;
    transform: translateY(10px);
  }
  100% {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes heart-float {
  0% {
    transform: translateY(0) scale(0.8) rotate(-45deg);
    opacity: 0;
  }
  15% {
    opacity: 0.85;
  }
  65% {
    opacity: 0.9;
  }
  80% {
    opacity: 0.2;
    transform: translateY(-85vh) scale(1) rotate(-45deg);
  }
  100% {
    opacity: 0;
    transform: translateY(-95vh) scale(0.2) rotate(-45deg);
  }
}

.days-together {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-weight: 600;
  opacity: 0.9;
  font-style: normal;
  font-family: 'Courier New', monospace;
  font-size: 0.95rem;
  letter-spacing: 0.05em;
}

.days-icon {
  font-size: 1.1rem;
}
</style>
