import { createRouter, createWebHashHistory } from 'vue-router';
const Foo = { template: '<div>foo</div>' };
const Bar = { template: '<div>bar</div>' };
// import VueRouter from 'vue-router';
import DailyLogs from '../DailyLogs.vue';
import DailyLogsForAdmin from '../DailyLogsForAdmin.vue';
import ManagementVehicles from '../ManagementVehicles.vue';
import Settings from '../Settings.vue';
import UsersForAdmin from '../UsersForAdmin.vue';
// import Tools from '@/views/Tools.vue';

// Vue.use(VueRouter);

const routes = [
	{
		path: '/',
		name: 'DailyLogs',
		component: DailyLogs,
	},
	{
		path: '/daily_logs_for_admin',
		name: 'DailyLogsForAdmin',
		component: DailyLogsForAdmin,
	},
	{
		path: '/management_vehicles',
		name: 'management_vehicles',
		component: ManagementVehicles,
	},
	{
		path: '/setting',
		name: 'setting',
		component: Settings,
	},
	{
		path: '/users_for_admin',
		name: 'users_for_admin',
		component: UsersForAdmin,
	},
];

const router = createRouter({
	history: createWebHashHistory(),
	routes: routes,
});

export default router;
