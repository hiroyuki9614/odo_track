<template lang="" v-cloak>
	<section class="daily_log_index">
		<div class="content-top mt-5 ms-5">
			<p class="float-end">更新日 2023/1/17</p>
			<p>アプリをご使用いただき誠にありがとうございます。</p>
			<p>このアプリはご使用者様の運転日報の作成・記録を簡易的に行う事を目的としております。</p>
      <p>このページでは下記の操作方法について説明します。</p><br>
    </div>
    <div class="index ms-5">
      <ul>
        <li class="my-3">運転日報の作成方法</li>
        <li class="my-3">運転日報の編集方法</li>
        <li class="my-3">運転日報の削除方法</li>
      </ul><br>
      <p>なお、その他の問い合わせにつきましては、お手数ですが、</p>
      <p>pikupin9441@gmail.com宛にお願い致します。</p><br>
		</div>
    <!-- /////////////////// -->
    <!--         PC用        -->
    <!-- /////////////////// -->
    <div class="create-log">
      <hr class="my-5" />
      <h3 class="m-3">運転日報の作成方法</h3><br>
      <v-carousel>
        <v-carousel-item
          src="images/CD1.png"
          cover
        ></v-carousel-item>
        <v-carousel-item
          src="images/CD2.png"
          cover
        ></v-carousel-item>
        <v-carousel-item
          src="images/CD3.png"
          cover
        ></v-carousel-item>
        <v-carousel-item
          src="images/CD4.png"
          cover
        ></v-carousel-item>
        <v-carousel-item
          src="images/CD5.png"
          cover
        ></v-carousel-item>
      </v-carousel>
    </div><br class="help-content">
      <!-- <div class="edit-log"> -->
        <hr class="my-5" />
        <h3 class="m-3">運転日報の編集方法</h3><br>
        <v-carousel>
          <v-carousel-item
            src="images/ED1.png"
            cover
          ></v-carousel-item>
          <v-carousel-item
            src="images/ED2.png"
            cover
          ></v-carousel-item>
          <v-carousel-item
            src="images/ED3.png"
            cover
          ></v-carousel-item>
        </v-carousel>
      <br class="help-content">
    <div class="delete-log">
      <hr class="my-5" />
      <h3 class="m-3">運転日報の削除方法</h3><br>
      <v-carousel>
        <v-carousel-item
          src="images/DD1.png"
          cover
        ></v-carousel-item>
        <v-carousel-item
          src="images/DD2.png"
          cover
        ></v-carousel-item>
        <v-carousel-item
          src="images/DD3.png"
          cover
        >
      </v-carousel-item>
      </v-carousel>
    </div>

	</section>
	<!-- Page Content -->
  <transition name="fade">
      <div id="pagetop" class="fixed right-0 bottom-0" v-show="scY > 30" @click="toTop">
        <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none"
             stroke="#4a5568"
             stroke-width="1" stroke-linecap="square" stroke-linejoin="arcs">
          <path d="M18 15l-6-6-6 6"/>
        </svg>
      </div>
    </transition>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue';

const scTimer = ref(0);
const scY = ref(0);

// スクロールイベントをハンドルする
const handleScroll = () => {
  if (scTimer.value) return;
  scTimer.value = setTimeout(() => {
    scY.value = window.scrollY;
    clearTimeout(scTimer.value);
    scTimer.value = 0;
  }, 100);
};

// トップに戻る
const toTop = () => {
  window.scrollTo({
    top: 0,
    behavior: "smooth"
  });
};

// コンポーネントがマウントされた後にスクロールイベントリスナーを追加
onMounted(() => {
  window.addEventListener('scroll', handleScroll);
});

// オプショナル: コンポーネントがアンマウントされる前にイベントリスナーを削除
onBeforeUnmount(() => {
  window.removeEventListener('scroll', handleScroll);
});

</script>
<style lang="css">
.content-top{
	margin: 1px;
}
/* div#pagetop {
  float: right;
} */
ul {
  list-style: none;
}

.create-log{
  margin: 50px auto 100px auto;
}
.edit-log {
  margin: 50px auto 100px auto;
}
.delete-log {
  margin: 45px auto 10px auto;
}

div#pagetop {
  position: fixed;
  right: 20px; /* 画面の右からの距離 */
  bottom: 20px; /* 画面の下からの距離 */
}

</style>
