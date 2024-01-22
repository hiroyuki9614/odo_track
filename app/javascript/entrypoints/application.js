// app/javascript/entrypoints/application.js

// To see this message, add the following to the `<head>` section in your
// views/layouts/application.html.erb
//
//    <%= vite_client_tag %>
//    <%= vite_javascript_tag 'application' %>
console.log('Vite ⚡️ Rails');

// If using a TypeScript entrypoint file:
//     <%= vite_typescript_tag 'application' %>
//
// If you want to use .jsx or .tsx, add the extension:
//     <%= vite_javascript_tag 'application.jsx' %>

console.log('Visit the guide for more information: ', 'https://vite-ruby.netlify.app/guide/rails');

// Example: Load Rails libraries in Vite.
//
// import * as Turbo from '@hotwired/turbo'
// Turbo.start()
//
// import ActiveStorage from '@rails/activestorage'
// ActiveStorage.start()
//
// // Import all channels.
// const channels = import.meta.globEager('./**/*_channel.js')

// Example: Import a stylesheet in app/frontend/index.css
// import '~/styles/theme.css';
// import '@hotwired/turbo-rails';
import './controllers/application.js';
import './controllers/hello_controller.js';
// import '../controllers/index.js';
import './custom/menu.js';
// import './custom/print.js';
import * as bootstrap from 'bootstrap';
import { createApp } from 'vue';
// import Vue from 'vue';
import { createVuetify } from 'vuetify';
import app from '../components/App.vue';
import usersForAdmin from '../components/UsersForAdmin.vue';
import dailyLogs from '../components/DailyLogs.vue';
import dailyLogsForAdmin from '../components/DailyLogsForAdmin.vue';
import managementVehicles from '../components/ManagementVehicles.vue';
import settings from '../components/Settings.vue';
import header from '../components/Header.vue';
import adminHeader from '../components/AdminHeader.vue';
import staticAdminHeader from '../components/StaticAdminHeader.vue';
import staticHeader from '../components/StaticHeader.vue';
import userHelp from '../components/UserHelp.vue';
import router from '../components/router/Index.js';
// import VueRouter from 'vue-router';

// import  from '../components/dailyLogs.vue';
// import vuetify from '../plugins/vuetify.js';
import axios from 'axios';
// import Vuetify from 'vuetify';
import 'vuetify/dist/vuetify.min.css';
// vuetifyのi18n対応
import { createVueI18nAdapter } from 'vuetify/locale/adapters/vue-i18n';
import { createI18n, useI18n } from 'vue-i18n';
import { en, ja } from 'vuetify/locale';
// vuelidateのI18対応
import * as validators from '@vuelidate/validators';

// i18nメッセージの内容
const messages = {
	en: {
		$vuetify: {
			...en,
			dataIterator: {
				rowsPerPageText: 'Items per page:',
				pageText: '{0}-{1} of {2}',
			},
		},
	},
	ja: {
		$vuetify: {
			...ja,
			dataIterator: {
				rowsPerPageText: 'Element per sida:',
				pageText: '{0}-{1} av {2}',
			},
		},
		validation: {
			required: 'このフィールドは必須です',
			minLength: "The {property} field has a value of '{model}', but it must have a min length of {min}.",
			// 他の日本語のバリデーションメッセージ
		},
	},
};

const i18n = createI18n({
	legacy: false, // Vuetify does not support the legacy mode of vue-i18n
	locale: 'ja',
	fallbackLocale: 'en',
	messages,
});

const vuetify = createVuetify({
	locale: {
		adapter: createVueI18nAdapter({ i18n, useI18n }),
	},
});

const App = createApp(app);
App.use(vuetify);
App.use(i18n);
App.use(router);
App.mount('#app');

const UsersForAdmin = createApp(usersForAdmin);
UsersForAdmin.use(vuetify);
UsersForAdmin.use(i18n);
UsersForAdmin.use(router);
UsersForAdmin.mount('#users_for_admin');

const DailyLogsApp = createApp(dailyLogs);
DailyLogsApp.use(vuetify);
DailyLogsApp.use(i18n);
DailyLogsApp.use(router);
DailyLogsApp.mount('#daily_logs');

const DailyLogsForAdminApp = createApp(dailyLogsForAdmin);
DailyLogsForAdminApp.use(vuetify);
DailyLogsForAdminApp.use(i18n);
DailyLogsForAdminApp.use(router);
DailyLogsForAdminApp.mount('#daily_logs_for_admin');

const ManagementVehiclesApp = createApp(managementVehicles);
ManagementVehiclesApp.use(vuetify);
ManagementVehiclesApp.use(i18n);
ManagementVehiclesApp.use(router);
ManagementVehiclesApp.mount('#management_vehicles');

const SettingsApp = createApp(settings);
SettingsApp.use(vuetify);
SettingsApp.use(i18n);
SettingsApp.use(router);
SettingsApp.mount('#settings');

const HeaderApp = createApp(header);
HeaderApp.use(vuetify);
HeaderApp.use(i18n);
HeaderApp.use(router);
HeaderApp.mount('#header');

const AdminHeaderApp = createApp(adminHeader);
AdminHeaderApp.use(vuetify);
AdminHeaderApp.use(i18n);
AdminHeaderApp.use(router);
AdminHeaderApp.mount('#admin_header');

const StaticAdminHeaderApp = createApp(staticAdminHeader);
StaticAdminHeaderApp.use(vuetify);
StaticAdminHeaderApp.use(i18n);
StaticAdminHeaderApp.use(router);
StaticAdminHeaderApp.mount('#static_admin_header');

const StaticHeaderApp = createApp(staticHeader);
StaticHeaderApp.use(vuetify);
StaticHeaderApp.use(i18n);
StaticHeaderApp.use(router);
StaticHeaderApp.mount('#static_header');
// Vue.component('v-select', vSelect);
const UserHelpApp = createApp(userHelp);
UserHelpApp.use(vuetify);
UserHelpApp.use(i18n);
UserHelpApp.use(router);
UserHelpApp.mount('#user_help');
