<template lang="">
	<v-app>
		<v-toolbar color="gray">
			<!-- <v-spacer></v-spacer> -->
			<v-tabs	v-model="tab" color="deep-purple-accent-4" align-tabs="start">
				<v-tab :value="1" to="/">運転日報</v-tab>
				<v-tab :value="2" to="/daily_logs_for_admin">日報一覧</v-tab>
				<v-tab :value="3" to="/users_for_admin">社員情報</v-tab>
				<v-tab :value="4" to="/management_vehicles">車両一覧</v-tab>
			</v-tabs>
			<v-spacer></v-spacer>
			<v-menu>
				<template v-slot:activator="{ props }">
					<v-btn icon="mdi-menu" v-bind="props"></v-btn>
				</template>
				<v-list>
					<v-list-item v-for="link in links" :base-color="link.color" :key="link.title" :href="link.url" :title="link.title" :prepend-icon="link.icon" @click="link.title === 'ログアウト' ? logout() : handleClick(link)">
						<v-list-item-title></v-list-item-title>
					</v-list-item>
				</v-list>
			</v-menu>
		</v-toolbar>
	</v-app>
</template>
<script setup>
import { ref } from 'vue';
import axios from 'axios';

const pageUrl = "http://h9614.link/"
const tab = ref(null);
const links = [
	// { title: '設定', icon: 'mdi mdi-cog', url: 'http://0.0.0.0:3000/daily_logs#/setting' },
	// { title: '設定', icon: 'mdi mdi-cog', url: 'https://lit-tor-41640-5f66b309ac09.herokuapp.com/daily_logs#/setting' },
	// { title: '設定', icon: 'mdi mdi-cog', url: 'http://54.95.118.214/daily_logs#/setting' },
	// { title: '設定', icon: 'mdi mdi-cog', url: 'http://54.95.118.214/daily_logs#/setting' },
	{ title: '設定', icon: 'mdi mdi-cog', url: 'https://h9614.link/daily_logs#/setting' },
	// { title: '出力', icon: 'mdi mdi-export-variant', url: 'http://0.0.0.0:3000/export_daily_logs/' },
	// { title: '出力', icon: 'mdi mdi-export-variant', url: 'https://lit-tor-41640-5f66b309ac09.herokuapp.com/export_daily_logs/' },
	// { title: '出力', icon: 'mdi mdi-export-variant', url: 'http://54.95.118.214/export_daily_logs/' },
	{ title: '出力', icon: 'mdi mdi-export-variant', url: 'https://h9614.link/export_daily_logs/' },
	// { title: '操作方法', icon: 'mdi mdi-help-circle', url: 'http://0.0.0.0:3000/user_help/' },
	// { title: '操作方法', icon: 'mdi mdi-help-circle', url: 'http://54.95.118.214/daily_logs#/user_help/' },
	{ title: '操作方法', icon: 'mdi mdi-help-circle', url: 'https://h9614.link/daily_logs#/user_help/' },
	// { title: '操作方法', icon: 'mdi mdi-help-circle', url: 'https://lit-tor-41640-5f66b309ac09.herokuapp.com/daily_logs#/user_help/' },
	{ title: 'ログアウト', icon: 'mdi mdi-logout', color: 'error' },
]
const account = [
	['Management', 'mdi-account-multiple-outline'],
]

const logout = () => {
	const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
	axios.delete('/auth/logout', { headers: { 'X-CSRF-Token': csrfToken } })
		.then(() => {
			// ログアウト成功時、指定のURLにリダイレクト
			window.location.href = pageUrl;
			location.reload()
			// window.location.href = 'https://lit-tor-41640-5f66b309ac09.herokuapp.com/';
		})
		.catch((error) => {
			// エラー処理
			console.error('ログアウト失敗:', error);
			location.reload()
		});
}
</script>
<style>
a.v-tab.v-tab {
	--v-btn-height: var(--v-tabs-height);
	border-radius: 0;
	min-width: 78px;
	/* background-color: aqua; */
}
@media (max-width: 600px) {
	element.style {
    height: 40px;
}
	.v-tab.v-tab {
		width: 78px;
		height: 40px;
		padding: 0px;
	}

	.v-btn--icon.v-btn--density-default {
		height: calc(var(--v-btn-height) + 0px);
		width: calc(var(--v-btn-height) + 0px);
	}
}

div .v-application__wrap {
	min-height: 1vh;
	min-height: 1dvh;
}
</style>
