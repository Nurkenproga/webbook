<script setup>
import { computed, ref, watch } from 'vue'

const props = defineProps({
  normalSrc: { type: String, required: true },
  loveSrc: { type: String, required: true },
  alt: { type: String, default: 'Наше фото' },
  captionTop: { type: String, default: '' },
  quote: { type: String, default: '' },
  contain: { type: Boolean, default: false }
})

const emit = defineEmits(['toggle'])

const isLove = ref(false)
const isLiked = ref(false)
const hearts = ref([])
const confetti = ref([])
const currentSrc = computed(() => (isLove.value ? props.loveSrc : props.normalSrc))

function toggle() {
  isLove.value = !isLove.value
  emit('toggle')
}

function toggleLike(e) {
  e.stopPropagation()
  isLiked.value = !isLiked.value
  
  if (isLiked.value) {
    createConfetti()
  }
}

function createConfetti() {
  const newConfetti = []
  const symbols = ['❤️', '💕', '💖', '✨', '💝']
  
  for (let i = 0; i < 30; i++) {
    const angle = (i / 30) * Math.PI * 2
    const velocity = 2 + Math.random() * 3
    const vx = Math.cos(angle) * velocity
    const vy = Math.sin(angle) * velocity - 1
    
    newConfetti.push({
      id: Math.random(),
      symbol: symbols[Math.floor(Math.random() * symbols.length)],
      x: 220,
      y: 32,
      vx,
      vy,
      life: 1.8
    })
  }
  confetti.value.push(...newConfetti)
  
  const animate = () => {
    confetti.value = confetti.value.map(c => ({
      ...c,
      x: c.x + c.vx,
      y: c.y + c.vy,
      vy: c.vy + 0.08,
      life: c.life - 0.01
    })).filter(c => c.life > 0)
    
    if (confetti.value.length > 0) {
      requestAnimationFrame(animate)
    }
  }
  animate()
}

function onDoubleClick(event) {
  const rect = event.currentTarget.getBoundingClientRect()
  const x = event.clientX - rect.left
  const y = event.clientY - rect.top
  
  const newHearts = []
  for (let i = 0; i < 8; i++) {
    newHearts.push({
      id: Math.random(),
      x,
      y,
      delay: i * 0.05
    })
  }
  hearts.value = newHearts
  
  setTimeout(() => {
    hearts.value = []
  }, 1200)
}

watch(
  () => props.normalSrc,
  () => {
    isLove.value = false
    isLiked.value = false
  }
)
</script>

<template>
  <div class="magic-card" :class="{ love: isLove, contain: contain }" @click="toggle">
    <span v-if="captionTop" class="caption top">{{ captionTop }}</span>
    <div class="photo-frame" :style="{ '--photo-url': `url(${currentSrc})` }" @dblclick="onDoubleClick">
      <img class="photo normal" :src="normalSrc" :alt="alt" loading="lazy" />
      <img class="photo love" :src="loveSrc" :alt="alt" loading="lazy" />
      <div class="glow"></div>
      
      <button class="like-btn" :class="{ liked: isLiked }" @click.stop="toggleLike">
        <span class="like-icon">❤️</span>
      </button>

      <div v-if="hearts.length > 0" class="floating-hearts">
        <div
          v-for="heart in hearts"
          :key="heart.id"
          class="heart"
          :style="{
            left: `${heart.x}px`,
            top: `${heart.y}px`,
            animationDelay: `${heart.delay}s`
          }"
        >
          ❤️
        </div>
      </div>

      <div v-if="confetti.length > 0" class="confetti-container">
        <div
          v-for="c in confetti"
          :key="c.id"
          class="confetti-item"
          :style="{
            left: `${c.x}px`,
            top: `${c.y}px`,
            opacity: c.life
          }"
        >
          {{ c.symbol }}
        </div>
      </div>
    </div>
    <p v-if="quote" class="quote">{{ quote }}</p>
  </div>
</template>

<style scoped>
.magic-card {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.6rem;
  cursor: pointer;
  padding: 0.6rem;
  border-radius: 18px;
  background:
    repeating-linear-gradient(
      0deg,
      transparent,
      transparent 2px,
      rgba(200, 150, 170, 0.03) 2px,
      rgba(200, 150, 170, 0.03) 4px
    ),
    rgba(255, 255, 255, 0.7);
  box-shadow: 0 16px 32px rgba(139, 58, 92, 0.18);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  width: min(360px, 92vw);
}

.magic-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 20px 40px rgba(139, 58, 92, 0.24);
}

.photo-frame {
  position: relative;
  width: 100%;
  aspect-ratio: 3/4;
  border-radius: 16px;
  overflow: hidden;
  background: #f7e7ee;
  box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.5);
}

.magic-card.contain .photo-frame::before {
  content: '';
  position: absolute;
  inset: -10%;
  background-image: var(--photo-url);
  background-size: cover;
  background-position: center;
  filter: blur(18px) saturate(1.1);
  transform: scale(1.1);
  opacity: 0.65;
}

.photo {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: opacity 0.6s ease, transform 0.6s ease;
}

.magic-card.contain .photo {
  object-fit: contain;
  background: rgba(255, 255, 255, 0.2);
}

.photo.normal {
  opacity: 1;
}

.photo.love {
  opacity: 0;
  transform: scale(1.05);
}

.magic-card.love .photo.normal {
  opacity: 0;
  transform: scale(1.04);
}

.magic-card.love .photo.love {
  opacity: 1;
  transform: scale(1);
}

.glow {
  position: absolute;
  inset: 0;
  background: radial-gradient(circle at 30% 20%, rgba(255, 255, 255, 0.5), transparent 55%);
  opacity: 0.7;
  mix-blend-mode: screen;
  pointer-events: none;
}

.like-btn {
  position: absolute;
  top: 10px;
  right: 10px;
  width: 44px;
  height: 44px;
  border: none;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.9);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.4rem;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  box-shadow: 0 6px 16px rgba(139, 58, 92, 0.2);
  z-index: 10;
}

.like-btn:hover {
  transform: scale(1.08);
  box-shadow: 0 8px 20px rgba(139, 58, 92, 0.3);
}

.like-btn.liked {
  animation: heart-pop 0.5s ease;
}

@keyframes heart-pop {
  0% { transform: scale(1); }
  50% { transform: scale(1.3); }
  100% { transform: scale(1.1); }
}

.floating-hearts {
  position: absolute;
  inset: 0;
  pointer-events: none;
}

.heart {
  position: absolute;
  font-size: 1.8rem;
  animation: float-up 1.2s ease-out forwards;
  opacity: 1;
}

@keyframes float-up {
  0% {
    opacity: 1;
    transform: translateY(0) scale(0.8);
  }
  100% {
    opacity: 0;
    transform: translateY(-100px) scale(0);
  }
}

.confetti-container {
  position: absolute;
  inset: 0;
  pointer-events: none;
}

.confetti-item {
  position: fixed;
  font-size: 2.2rem;
  pointer-events: none;
}

.caption {
  font-size: 0.85rem;
  color: #7a3f58;
  text-align: center;
}

.caption.top {
  font-weight: 600;
}

.quote {
  margin: 0;
  font-size: 0.8rem;
  color: #8b3a5c;
  font-style: italic;
  opacity: 0.85;
}

.tap-hint {
  position: absolute;
  top: 14px;
  right: 10px;
  font-size: 0.65rem;
  padding: 0.2rem 0.5rem;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.75);
  color: #8b3a5c;
  box-shadow: 0 4px 12px rgba(139, 58, 92, 0.12);
}
</style>
