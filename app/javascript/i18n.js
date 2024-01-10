import { createI18n, useI18n } from 'vue-i18n';

const messages = {
	ja: {
		$vuetify: {
			dataIterator: {
				rowsPerPageText: 'ページあたりの行数：',
				noDataText: '利用可能なデータがありません。',
			},
		},
	},
};

const i18n = createI18n({
	locale: 'ja',
	fallbackLocale: 'ja',
	messages,
});

export default i18n;
