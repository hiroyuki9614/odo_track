<template lang="">
	<section class="daily_log_index">
		<div class="bg-image h-100">
			<!-- 検索フォーム -->
			<!-- テーブル要素 -->
			<v-layout v-resize="onResize" column>
				<v-data-table v-model:expanded="expanded" :search="search" :headers="headers" :items="items" show-expand :hide-headers="isMobile" :class="{mobile: isMobile}">
				<!-- テーブルタイトル -->
					<template v-slot:top>
						<v-toolbar flat>
							<div v-if="!isMobile" style="display: flex; align-items: center;">
								<v-toolbar-title class="table-title">運転日報</v-toolbar-title>
								<v-divider class="mx-4" inset vertical></v-divider>
							</div>
							<div class="search-field me-5">
								<v-text-field v-model="search" label="検索" single-line hide-details class="search-form" density="compact"/>
							</div>
							<v-divider class="mx-4" inset vertical></v-divider>
							<v-dialog v-model="dialog" max-width="1000px">
								<template v-slot:activator="{ props }">
									<v-btn color="primary" dark class="" v-bind="props" @click="fetchInitialData"> 新規作成 </v-btn>
								</template>
								<!-- 新規作成ダイアログの内容 -->
								<v-card class="pt-5">
									<!-- <v-form fast-fail @submit.prevent> -->
									<v-form ref="form">
										<v-card-title>
											<span class="text-h5 ms-5">{{ formTitle }}</span>
										</v-card-title>
										<v-card-text class="card-text">
											<v-container	v-if="!isMobile">
												<v-row>
													<!-- フォームの内容 -->
														<v-col cols="12" sm="4" md="3">
															<v-select v-model="vehicle_id" label="車両" :rules="vehicleRules" @update:modelValue="onChangeVehicleSelect" :items="newFavoriteVehicles" item-title="vehicle_name" item-value="vehicle_id" persistent-hint return-object single-line></v-select>
														</v-col>
														<v-col cols="12" sm="4" md="3">
															<v-text-field v-model="departure_datetime" label="出発日時" :rules="departureDatetimeRules" />
															<v-text-field v-model="departure_distance" required label="出発時の距離" :rules="departureDistanceRules" />
															<v-text-field v-model="departure_location" required label="出発場所" :rules="departureLocationRules" />
														</v-col>
														<v-col cols="12" sm="4" md="3">
															<v-text-field v-model="arrival_datetime" required label="到着日時" :rules="arrivalDatetimeRules" />
															<v-text-field v-model="arrival_distance" required label="到着時の距離" :rules="arrivalDistanceRules" />
															<v-text-field v-model="arrival_location" required label="目的地" :rules="arrivalLocationRules" />
														</v-col>
														<v-col cols="12" sm="4" md="3">
															<v-textarea v-model="note" label="備考" variant="filled" row-height="100" :rules="noteRules" class="form-note" />
															<div v-if="editedIndex == -1">
																<v-switch v-model="is_alcohol_check" label="アルコール検査" color="primary" :rules="alcoholCheckRules" />
															</div>
															<div v-else>
																<v-switch color="primary" v-model="is_alcohol_check" :model-value="true" disabled label="アルコール検査"></v-switch>
															</div>
													</v-col>
												</v-row>
											</v-container>
											<v-container v-if="isMobile">
												<v-row>
													<!-- フォームの内容 -->
													<v-col cols="12" sm="4" md="3">
														<v-select v-model="vehicle_id" label="車両" :rules="vehicleRules" @update:modelValue="onChangeVehicleSelect" :items="newFavoriteVehicles" item-title="vehicle_name" item-value="vehicle_id" persistent-hint return-object single-line></v-select>
														<v-text-field v-model="departure_datetime" label="出発日時" :rules="departureDatetimeRules" />
														<v-text-field v-model="arrival_datetime" required label="到着日時" :rules="arrivalDatetimeRules" />
														<v-text-field v-model="departure_distance" required label="出発時の距離" :rules="departureDistanceRules" />
														<v-text-field v-model="arrival_distance" required label="到着時の距離" :rules="arrivalDistanceRules" />
														<v-text-field v-model="departure_location" required label="出発場所" :rules="departureLocationRules" />
														<v-text-field v-model="arrival_location" required label="目的地" :rules="arrivalLocationRules" />
														<v-textarea v-model="note" label="備考" variant="filled" row-height="100" :rules="noteRules" class="form-note" />
														<div v-if="editedIndex == -1">
															<v-switch v-model="is_alcohol_check" label="アルコール検査" color="primary" :rules="alcoholCheckRules" />
														</div>
														<div v-else>
															<v-switch color="primary" v-model="is_alcohol_check" :model-value="true" disabled label="アルコール検査"></v-switch>
														</div>
													</v-col>
												</v-row>
											</v-container>
										</v-card-text>
										<!-- 新規作成ダイアログのボタン -->
										<v-card-actions class="card-action">
											<v-spacer></v-spacer>
											<v-btn color="blue-darken-1" variant="text" @click="close"> 取り消し </v-btn>
											<v-btn color="blue-darken-1" variant="text" type="submit" @click="save"> 保存 </v-btn>
										</v-card-actions>
									</v-form>
								</v-card>
							</v-dialog>
							<!-- 削除ダイアログ -->
							<v-dialog v-model="dialogDelete" max-width="500px">
								<v-card>
									<v-card-title class="body-2 text-center">この運転日報を削除します。</v-card-title>
									<v-card-actions>
										<v-spacer></v-spacer>
										<v-btn color="blue-darken-1" variant="text" @click="closeDelete">Cancel</v-btn>
										<v-btn type="submit" color="blue-darken-1" @click="deleteItemConfirm(item_id)">OK</v-btn>
										<v-spacer></v-spacer>
									</v-card-actions>
								</v-card>
							</v-dialog>
							<v-dialog v-model="dialogError" max-width="500px">
								<v-card>
									<v-card-title class="body-2 text-center">エラーが発生しました。</v-card-title>
									<p class="text-center">申し訳ございません。</p>
									<p class="text-center">エラーが発生し、先程の投稿は無効となりました。</p>
									<p class="text-center">お手数ですが、再度ご入力下さい。</p>
									<v-card-actions>
										<v-spacer></v-spacer>
										<v-btn color="blue-darken-1" variant="text" @click="closeError">閉じる</v-btn>
										<v-spacer></v-spacer>
									</v-card-actions>
								</v-card>
							</v-dialog>
						</v-toolbar>
					</template>
					<!-- テーブルの拡張 -->
					<template v-slot:expanded-row="{ columns, item, index}">
						<tr>
							<td :colspan="columns.length">
								<div class="flex-container">
									<div class="expanded-value">
										<p class="vehicle">車両名: {{ item.vehicle_name }} - {{ item.vehicle_number }}</p>
										<p class="is_alcohol_check">アルコールチェック: {{ item.is_alcohol_check ? '実施済' : '未実施' }}</p>
										<p class="is_studless" v-if="item.is_studless_tire">スタッドレスタイヤ: 装着</p>
										<p class="note">備考: {{ item.note }}</p>
									</div>
									<!-- アイコン -->
									<div class="table-icons">
											<v-tooltip v-model="editShow[index]" location="top">
												<template v-slot:activator="{ props }">
														<v-icon @mouseenter="editShow[index] = true" @mouseleave="editShow[index] = false" size="small" v-bind="props" class="me-2" @click="editItem(item.id)"> mdi-pencil </v-icon>
												</template>
												<span>編集</span>
											</v-tooltip>
											<v-tooltip v-model="deleteShow[index]" location="top">
												<template v-slot:activator="{ props }">
													<v-icon @mouseenter="deleteShow[index] = true" @mouseleave="deleteShow[index] = false" size="small" color="error" v-bind="props" @click="deleteItem(item)" class="delete-icon"> mdi-delete </v-icon>
												</template>
												<span>削除</span>
											</v-tooltip>
									</div>
								</div>
							</td>
						</tr>
					</template>
				</v-data-table>
			</v-layout>
		</div>
	</section>
</template>

<script setup>
import { ref, reactive, computed, watch, onMounted, nextTick, toRaw } from 'vue';
import axios from 'axios';

// 新規作成ダイアログの初期状態
const dialog = ref(false);
const dialogDelete = ref(false);
const dialogError = ref(false);

const editShow = ref({});
const deleteShow = ref({});
const search = ref('');
const form = ref();
const departure_datetime = ref('');
const arrival_datetime = ref('');
const departure_distance = ref('');
const vehicle_current_drive_distance = ref('');
const arrival_distance = ref('');
const departure_location = ref('');
const arrival_location = ref('');
const note = ref('');
const is_alcohol_check = ref(false);
const is_studless_tire = ref(false);
const vehicle_id = ref('');
const current_vehicle_id = ref('');
const formErrors = ref({});
const newFavoriteVehicles = ref([]);
const items = ref([]);
const item_id = ref(0);
const isMobile = ref(false);
const selected = ref([]);

// Vehicleテーブルから車両の最後の走行距離を引っ張る
const onChangeVehicleSelect = (value) => {
	let v = value.vehicle_id
	current_vehicle_id.value = v
	return departure_distance.value = value.vehicle_current_drive_distance;
};

const onResize = () => {
	if (window.innerWidth < 600)
		return isMobile.value = true;
	else
		return isMobile.value = false;
}

const editedIndex = ref(-1);
const expanded = ref([]);
const API_URL = `/api/daily_logs/`;
// const isEditing = ref(false)
const errors = ref('');
const newDailyLog = ref('');
const itemdata = ref([]);

// indexテーブルのヘッダー定義
const headers = [
	{ title: '作成日時', align: 'center', key: 'created_at', minWidth: 110 },
	{ title: '出発日時', align: 'center', key: 'departure_datetime',	minWidth: 110 },
	{ title: '到着日時', align: 'center', key: 'arrival_datetime',	minWidth: 110 },
	{ title: '出発時の距離', align: 'center', key: 'departure_distance',	minWidth: 100 },
	{ title: '到着時の距離', align: 'center', key: 'arrival_distance', minWidth: 100 },
	{ title: '出発場所', align: 'center', key: 'departure_location',	minWidth: 110 },
	{ title: '目的地', align: 'center', key: 'arrival_location',	minWidth: 100 },
];

// バリデーション一覧
const validDatePattern = /^[0-9\-\/ :]*$/;
const validNumberPattern = /[0-9０-９]+$/;
const validTimePattern = /^\d{4}[\/-]\d{2}[\/-]\d{2} \d{2}:\d{2}$/;
// バリデーションを判定する。
// カスタムバリデーション
const ArrivalAfterDepartureDateTime = () => {
	if (departure_datetime.value >= arrival_datetime.value) {
		return false;
	}
	return true;
};
const ArrivalAfterDepartureDistance = () => {
	const departure = parseFloat(departure_distance.value);
	const arrival = parseFloat(arrival_distance.value);

	if (!isNaN(departure) && !isNaN(arrival)) {
		if (departure >= arrival) {
			return false;
		}
	}
	return true;
};

const isValid = () => {
	if (departureDatetimeIsValid.value && arrivalDatetimeIsValid.value && departureLocationIsValid.value && arrivalDatetimeIsValid.value &&
		departureLocationIsValid.value && arrivalLocationIsValid.value && noteIsValid.value && alcoholCheckIsValid.value) {
		return true;
	} else {
		return false;
	}
};
const vehicleIsValid = ref(true)
const vehicleRules = [
	value => {
		if (!value) {
			vehicleIsValid.value = false;
			return '車両を選択して下さい。';
		}
		vehicleIsValid.value = true;
		return true;
	}
];
const departureDatetimeIsValid = ref(true)
const departureDatetimeRules = [
	value => {
		if (!value) {
			departureDatetimeIsValid.value = false;
			return '出発日時を入力して下さい。';
		}
		if (!validDatePattern.test(value)) {
			departureDatetimeIsValid.value = false;
			return '無効な形式です。半角数字、-、/、:のみ使用できます。';
		}
		if (!ArrivalAfterDepartureDateTime()) {
			departureDatetimeIsValid.value = false;
			return '出発時間が到着時間を超えています。';
		}
		if (!validTimePattern.test(value)) {
			departureDatetimeIsValid.value = false;
			return '日付は yyyy/mm/dd hh:mm または yyyy-mm-dd hh:mm の形式である必要があります。';
		}
		departureDatetimeIsValid.value = true;
		return true;
	}
];
const arrivalDatetimeIsValid = ref(true)
const arrivalDatetimeRules = [
	value => {
		if (!value) {
			arrivalDatetimeIsValid.value = false;
			return '到着日時を入力して下さい。';
		}
		if (!ArrivalAfterDepartureDateTime()) {
			departureDatetimeIsValid.value = false;
			return '出発時間が到着時間を超えています。';
		}
		if (!validDatePattern.test(value)) {
			arrivalDatetimeIsValid.value = false;
			return '無効な形式です。半角数字、-、/、:のみ使用できます。';
		}
		if (!validTimePattern.test(value)) {
			arrivalDatetimeIsValid.value = false;
			return '日付は yyyy/mm/dd hh:mm または yyyy-mm-dd hh:mm の形式である必要があります。';
		}

		arrivalDatetimeIsValid.value = true;

		return true;
	},
]
const departureDistanceIsValid = ref(true)
const departureDistanceRules = [
	value => {
		if (!value) {
			departureDistanceIsValid.value = false;
			return '出発時の距離を入力して下さい。';
		}
		if (!validNumberPattern.test(value)) {
			departureDistanceIsValid.value = false;
			return '無効な形式です。数字のみ使用できます。';
		}
		if (!ArrivalAfterDepartureDistance()) {
			departureDistanceIsValid.value = false;
			return '出発時の距離が到着時の距離を超えています。';
		}
		departureDistanceIsValid.value = true;
		return true;
	},
]
const arrivalDistanceIsValid = ref(true)
const arrivalDistanceRules = [
	value => {
		if (!value) {
			arrivalDistanceIsValid.value = false;
			return '到着時の距離を入力して下さい。'
		}
		if (!ArrivalAfterDepartureDistance()) {
			departureDistanceIsValid.value = false;
			return '出発時の距離が到着時の距離を超えています。';
		}
		if (!validNumberPattern.test(value)) {
			arrivalDistanceIsValid.value = false;
			return '無効な形式です。数字のみ使用できます。';
		}
		arrivalDistanceIsValid.value = true;
		return true;
	},
]
const departureLocationIsValid = ref(true)
const departureLocationRules = [
	value => {
		if (!value) {
			departureLocationIsValid.value = false;
			return '出発場所を入力して下さい。'
		}
		if (value.length > 100) {
			departureLocationIsValid.value = false;
			return '100文字以内で入力して下さい。'
		}

		departureLocationIsValid.value = true;

		return true;
	}
]
const noteIsValid = ref(true)
const noteRules = [
	value => {
		if (value.length > 1000) {
			noteIsValid.value = false;
			return '1000文字以内で入力して下さい。'
		}
		noteIsValid.value = true;
		return true;
	},
]
const arrivalLocationIsValid = ref(true)
const arrivalLocationRules = [
	value => {
		if (!value) {
			arrivalLocationIsValid.value = false;
			return '目的地を入力して下さい。'
		}
		if (value.length > 100) {
			arrivalLocationIsValid.value = false;
			return '100文字以内で入力して下さい。'
		}
		arrivalLocationIsValid.value = true;
		return true;
	}
]
const alcoholCheckIsValid = ref(true)
const alcoholCheckRules = [
	value => {
		if (value == false) {
			alcoholCheckIsValid.value = false;
			return 'アルコール検査を実施して下さい。'
		}
		alcoholCheckIsValid.value = true;
		return true;
	},
]

// 編集中のアイテムが新規アイテムか既存アイテムかに基づいて、フォームのタイトルを動的に計算する。
const formTitle = computed(() => {
	return editedIndex.value === -1 ? '運転日報を作成する' : '運転日報を編集する';
});

const props = computed(() => {
	return {
		label: 'Switch',
		inset: model.value === 'inset' || undefined,
		indeterminate: indeterminate.value || undefined,
	}
})

// daily_logs_controllerからJSONを取得(index)
const fetchDailyLogs = () => {
	const url = API_URL;
	axios.get(url).then(res => {
		items.value = res.data.daily_logs;
		newFavoriteVehicles.value = res.data.favorite_vehicles;
		if (newFavoriteVehicles.value.length > 0) {
			vehicle_id.value = newFavoriteVehicles.value[0].vehicle_id;
			vehicle_current_drive_distance.value = newFavoriteVehicles.value[0].vehicle_current_drive_distance;
			current_vehicle_id.value = vehicle_id.value
		}
		if (newFavoriteVehicles.value.length === 0) {
			alert("運転する車両が登録されていません。 \n運転日報を作成する前に、設定から運転する車両を登録して下さい。")
			window.location.href = "/daily_logs#/setting";
		}
	}).catch(error => {
		console.error(error);
	});
};

// fetchDailyLogsを初期化
fetchDailyLogs();

// daily_logs_controllerからJSONを取得(new) フォームの初期値をバックエンドより取得
const fetchInitialData = async () => {
	const url = `${API_URL}new`;
	axios.get(url).then(res => {
		console.log(res.data);
		console.log(editedIndex.value)
		const newDailyLog = res.data.daily_log;
		departure_datetime.value = newDailyLog.departure_datetime || '';
		arrival_datetime.value = newDailyLog.arrival_datetime || '';
		departure_distance.value = vehicle_current_drive_distance.value || '';
		arrival_distance.value = newDailyLog.arrival_distance || '';
		departure_location.value = newDailyLog.departure_location || '';
		arrival_location.value = newDailyLog.arrival_location || '';
		note.value = newDailyLog.note || '';
		is_alcohol_check.value = newDailyLog.is_alcohol_check;
		is_studless_tire.value = newDailyLog.is_studless_tire;
	}).catch(error => {
		console.error(error);
	});
};

// 投稿(create) daily_logを作成する。
const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
const createItem = async () => {
	try {
		const res = await fetch(API_URL, {
			method: 'POST',
			withCredentials: true,
			headers: {
				'Content-Type': 'application/json',
				'X-CSRF-Token': csrfToken
			},
			body: JSON.stringify({
				departure_datetime: departure_datetime.value,
				arrival_datetime: arrival_datetime.value,
				departure_distance: departure_distance.value,
				arrival_distance: arrival_distance.value,
				departure_location: departure_location.value,
				arrival_location: arrival_location.value,
				note: note.value,
				vehicle_id: current_vehicle_id.value,
				is_alcohol_check: is_alcohol_check.value,
				is_studless_tire: is_studless_tire.value
				// user_id: user_id.value, // 必要に応じてコメントアウトを解除
			})
		});
		// 失敗した場合の処理
		if (!res.ok) {
			const errorData = await res.json(); // エラーレスポンスの内容を取得
			console.error('Error Response:', errorData); // エラーレスポンスをコンソールに表示
			formErrors.value = errorData.errors || {};
			if (isValid.value) {
				return dialogError.value = true;
			}
			console.error('フォームエラー:', JSON.stringify(toRaw(formErrors.value), null, 2));
			if (errorData.errors) {
				// エラーメッセージがある場合はそれを表示
				console.error('Validation Errors:', errorData.errors);
			}
			const message = `An error has occured: ${res.status} - ${res.statusText}`;
			throw new Error(message);
		}
		const data = await res.json();
		console.log(data);
		items.value.push(data);
		location.reload()
	} catch (err) {
		console.error('Error:', err.message); // エラー情報をコンソールに表示
		console.log("エラー内容：" + formErrors.value)
		if (isValid.value) {
			dialogError.value = true;
		}
	}
}

const editItem = async (id) => {
	const item = items.value.find(item => item.id === id)
	editedIndex.value = items.value.indexOf(item)
	console.log(editedIndex.value)
	departure_datetime.value = item.departure_datetime
	arrival_datetime.value = item.arrival_datetime
	departure_distance.value = item.departure_distance
	arrival_distance.value = item.arrival_distance
	departure_location.value = item.departure_location
	arrival_location.value = item.arrival_location
	note.value = item.note
	is_alcohol_check.value = item.is_alcohol_check
	is_studless_tire.value = item.is_studless_tire
	item_id.value = item.id
	// vehicle_id.value = newFavoriteVehicles.value[0].vehicle_id;
	vehicle_id.value = item.vehicle_id
	// isEditing.value = true
	dialog.value = true
}

// 編集(update) daily_logをupdateする。
const updateItem = async () => {
	try {
		console.log(item_id)
		const res = await fetch(`${API_URL}${item_id.value}`, {
			method: 'PUT',
			headers: {
				'Content-Type': 'application/json',
				'X-CSRF-Token': csrfToken
			},
			body: JSON.stringify({
				departure_datetime: departure_datetime.value,
				arrival_datetime: arrival_datetime.value,
				departure_distance: departure_distance.value,
				arrival_distance: arrival_distance.value,
				departure_location: departure_location.value,
				arrival_location: arrival_location.value,
				note: note.value,
				vehicle_id: current_vehicle_id.value,
				is_alcohol_check: is_alcohol_check.value,
				is_studless_tire: is_studless_tire.value,
				// id: id.value,
				// user_id: user_id.value, // 必要に応じてコメントアウトを解除
			})
		});
		// 失敗した場合の処理
		if (!res.ok) {
			const errorData = await res.json(); // エラーレスポンスの内容を取得
			console.error('Error Response:', errorData); // エラーレスポンスをコンソールに表示
			formErrors.value = errorData.errors || {};
			console.error('フォームエラー:', JSON.stringify(toRaw(formErrors.value), null, 2));
			if (isValid.value) {
				dialogError.value = true;
			}
			if (errorData.errors) {
				// エラーメッセージがある場合はそれを表示
				console.error('Validation Errors:', errorData.errors);
			}
			const message = `An error has occured: ${res.status} - ${res.statusText}`;
			throw new Error(message);
		}

		const data = await res.json();

		const index = items.value.findIndex(item => item.id === data.id)
		items.value[index] = data
	} catch (err) {
		console.error('Error:', err.message); // エラー情報をコンソールに表示
		console.log("エラー内容：" + formErrors.value)
		if (isValid.value) {
			dialogError.value = true;
		}
	}
}
function deleteItem(item) {
	item_id.value = item.id
	dialogDelete.value = true
}
const deleteItemConfirm = async (id) => {
	await fetch(`${API_URL}${id}`, {
		method: 'DELETE',
		headers: { 'X-CSRF-Token': csrfToken }
	})
	items.value = items.value.filter(item => item.id !== id)
	dialogDelete.value = false
}

function close() {
	dialog.value = false
	nextTick(() => {
		editedIndex.value = -1
	})
}
function closeDelete() {
	dialogDelete.value = false
	nextTick(() => {
		editedIndex.value = -1
	})
}
function closeError() {
	dialogError.value = false
	nextTick(() => {
		editedIndex.value = -1
	})
}
function save() {
	// 編集時
	if (editedIndex.value > -1) {
		// console.log('編集')
		updateItem();
		// 新規作成時
	} else {
		// console.log('新規作成')
		createItem();
	}
	if (isValid) {
		// close()
	}
}

// ダイアログが閉じられたときの動作。
watch(dialog, val => {
	val || close()
})
watch(dialogDelete, val => {
	val || closeDelete()
})
watch(dialogError, val => {
	val || closeError()
})
</script>
<style lang="css">

element.style {
		z-index: 900;
		position: relative;
		overflow: hidden;
		padding-top: 0px;
}
.flex-container {
	display: flex;
}

.expanded-value {
	display: flex;
	justify-content: auto;
	/* 要素間のスペースを均等に分配 */
	align-items: center;
	/* 要素を垂直方向の中央に配置 */
	padding-left: 5px;
}

.table-icons {
	display: flex;
	align-items: center;
	justify-content: flex-end;
	margin-left: auto;
}

.vehicle {
	width: 170px;
	padding-top: 15px;
}

.studless {
	width: 170px;
	padding-top: 15px;
}

.is_alcohol_check {
	width: 200px;
	padding-top: 15px;
}

.note {
	width: 200px;
	/* 幅の設定 */
	max-height: 100px;
	/* 最大高さの設定 */
	overflow: auto;
	/* 高さが最大値を超えた場合にスクロールバーを表示 */
	word-break: break-word;
	/* 単語の途中でも折り返しを許可 */
	padding-top: 15px;
}

.search-field {
	width: 200px;
	margin: auto;
	display: flex;
	/* フレックスボックスを有効化 */
	align-items: center;
	/* アイテムを垂直方向の中央に配置 */
	justify-content: center;
	/* アイテムを水平方向の中央に配置 */
}

.table-title {
	padding-left: 20px;
}

.card-text {
	/* background-color: black; */
	max-height: 270px;
}

@media screen and (max-width: 768px) {
	div.card-action{
		margin-top: 550px;
	}
	.mobile table.v-table tr {
		max-width: 100%;
		position: relative;
		display: block;
	}

	.mobile table.v-table tr:nth-child(odd) {
		border-left: 6px solid deeppink;
	}

	.mobile table.v-table tr:nth-child(even) {
		border-left: 6px solid cyan;
	}

	.mobile table.v-table tr td {
		display: flex;
		width: 100%;
		border-bottom: 1px solid #f5f5f5;
		height: auto;
		padding: 10px;
	}

	.mobile table.v-table tr td ul li:before {
		content: attr(data-label);
		padding-right: .5em;
		text-align: left;
		display: block;
		color: #999;

	}

	.v-datatable__actions__select {
		width: 50%;
		margin: 0px;
		justify-content: flex-start;
	}

	.mobile .theme--light.v-table tbody tr:hover:not(.v-datatable__expand-row) {
		background: transparent;
	}

}

.flex-content {
	padding: 0;
	margin: 0;
	list-style: none;
	display: flex;
	flex-wrap: wrap;
	width: 100%;
}

.flex-item {
	padding: 5px;
	width: 50%;
	height: 40px;
	font-weight: bold;
}
</style>
