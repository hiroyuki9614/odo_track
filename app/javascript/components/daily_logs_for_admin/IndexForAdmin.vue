<template lang="">
	<section class="vehicle_index">
		<div class="bg-image h-100">
			<!-- ================================== -->
			<!-- ここから論理削除した日報のテーブル -->
			<!-- ================================== -->
			<div v-if="discardedDailyLogsIndex">
				<!-- 検索フォーム -->
				<v-layout v-resize="onResize" column>
					<v-data-table v-model:expanded="expanded" :search="search" :headers="headers" :items="discarded_items" show-expand >
						<!-- テーブルタイトル -->
						<template v-slot:top>
							<v-toolbar flat>
								<div v-if="!isMobile" style="display: flex; align-items: center;">
									<v-toolbar-title class="table-title">日報一覧</v-toolbar-title>
									<v-divider class="mx-4" inset vertical></v-divider>
								</div>
								<v-checkbox v-model="discardedDailyLogsIndex" :label="`削除した日報を表示する`" class="discarded-index-check-box" style="display: flex; justify-content: end; font-size: x-small" />
								<v-divider class="mx-4" inset vertical></v-divider>
								<div class="search-field">
									<v-text-field v-model="search" label="検索" single-line hide-details class="search-form" density="compact" />
								</div>
								<v-divider class="mx-4" inset vertical></v-divider>
								<!-- 削除取消ダイアログ -->
								<v-dialog v-model="dialogUndelete" max-width="500px">
									<v-card>
										<v-card-title class="text-center">この車両の削除を取消します。</v-card-title>
										<v-card-actions>
											<v-spacer></v-spacer>
											<v-btn color="blue-darken-1" variant="text" @click="closeUndelete">Cancel</v-btn>
											<v-btn type="submit" color="blue-darken-1" @click="undeleteItemConfirm(item_id)">OK</v-btn>
											<v-spacer></v-spacer>
										</v-card-actions>
									</v-card>
								</v-dialog>
								<v-dialog v-model="dialogDestroy" max-width="500px">
									<v-card>
										<v-card-title class="text-center">この日報を削除します。</v-card-title>
										<p class="text-center" style="margin-bottom: 0px">この日報は完全に削除されます。</p>
										<v-card-actions>
											<v-spacer></v-spacer>
											<v-btn color="blue-darken-1" variant="text" @click="closeDestroy">Cancel</v-btn>
											<v-btn type="submit" color="blue-darken-1" @click="destroyItemConfirm(item_id)">OK</v-btn>
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
											<v-tooltip v-model="undeleteShow[index]" location="top">
												<template v-slot:activator="{ props }">
													<v-icon @mouseenter="undeleteShow[index] = true" @mouseleave="undeleteShow[index] = false" size="small" color="green" v-bind="props" @click="undeleteItem(item)" class="delete-icon me-2"> mdi-undo </v-icon>
												</template>
												<span>取消</span>
											</v-tooltip>
											<v-tooltip v-model="deleteShow[index]" location="top">
												<template v-slot:activator="{ props }">
													<v-icon @mouseenter="deleteShow[index] = true" @mouseleave="deleteShow[index] = false" size="small" color="error" v-bind="props" @click="destroyItem(item)" class="delete-icon"> mdi-delete </v-icon>
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
			<!-- ================================== -->
			<!-- ここから通常の日報のテーブル -->
			<!-- ================================== -->
			<div v-else>
				<v-layout v-resize="onResize" column>
					<v-data-table v-model:expanded="expanded" :search="search" :headers="headers" :items="items" show-expand >
						<!-- テーブルタイトル -->
						<template v-slot:top>
							<v-toolbar flat>
								<div v-if="!isMobile" style="display: flex; align-items: center;">
									<v-toolbar-title class="table-title">日報一覧</v-toolbar-title>
									<v-divider class="mx-4" inset vertical></v-divider>
								</div>
								<v-checkbox v-model="discardedDailyLogsIndex" :label="`削除した日報を表示する`" class="discarded-index-check-box" style="display: flex; justify-content: end; font-size: x-small" />
								<v-divider class="mx-4" inset vertical></v-divider>
								<div class="search-field">
									<v-text-field v-model="search" label="検索" single-line hide-details class="search-form" density="compact" />
								</div>
								<v-divider class="mx-4" inset vertical></v-divider>
								<v-dialog v-model="dialog" max-width="1000px">
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
														<input type="hidden" v-model="hiddenVehicle" />
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
												<v-container	v-if="isMobile">
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
											<!-- 新規作成/編集ダイアログのボタン -->
											<v-card-actions class="card-action">
												<v-spacer></v-spacer>
												<v-btn color="blue-darken-1" variant="text" @click="close"> 取り消し </v-btn>
												<v-btn color="blue-darken-1" variant="text" type="submit" @click="save"> 保存 </v-btn>
											</v-card-actions>
										</v-form>
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
								<v-dialog v-model="dialogDelete" max-width="500px">
									<v-card>
										<v-card-title class="text-center">この日報を除外します。</v-card-title>
										<p class="text-center" style="margin-bottom: 0px">この日報は一覧に表示されなくなります。</p>
										<p class="text-center text-body-2" style="margin-top: 0px">(関連付けられた日報は削除されません)</p>
										<v-card-actions>
											<v-spacer></v-spacer>
											<v-btn color="blue-darken-1" variant="text" @click="closeDelete">Cancel</v-btn>
											<v-btn type="submit" color="blue-darken-1" @click="deleteItemConfirm(item_id)">OK</v-btn>
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
		</div>
	</section>
</template>


<script setup>
import { ref, reactive, computed, watch, onMounted, nextTick, toRaw } from 'vue';
import axios from 'axios';

// 新規作成ダイアログの初期状態
const dialog = ref(false);
const dialogNotice = ref(false);
const changeEmail = localStorage.getItem("change");
const dialogDelete = ref(false);
const dialogDestroy = ref(false);
const dialogUndelete = ref(false);
const dialogError = ref(false);
const expanded = ref([]);

const editShow = ref({});
const deleteShow = ref({});
const undeleteShow = ref({});
const search = ref('');
const form = ref();
// DailyLogモデルの項目
const created_at = ref('');
const user_name = ref('');
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
const user_id = ref('');
const discarded_at = ref('');

const items = ref([]);
const vehicles = ref([]);
const item_id = ref(0)
const discarded_items = ref([]);

const formErrors = ref({});
const discardedDailyLogsIndex = ref(false);
const editedIndex = ref(-1);
const isMobile = ref(false);
const API_URL = `/api/daily_logs_for_admin/`;

const onResize = () => {
	if (window.innerWidth < 600)
		return isMobile.value = true;
	else
		return isMobile.value = false;
}

// indexテーブルのヘッダー定義
const headers = [
	{ title: '運転者', align: 'center', key: 'user_name', minWidth: 110 },
	{ title: '作成日時', align: 'center', key: 'created_at', minWidth: 110 },
	{ title: '出発日時', align: 'center', key: 'departure_datetime', minWidth: 110 },
	{ title: '到着日時', align: 'center', key: 'arrival_datetime', minWidth: 110 },
	{ title: '出発時の距離', align: 'center', key: 'departure_distance', minWidth: 110 },
	{ title: '到着時の距離', align: 'center', key: 'arrival_distance', minWidth: 110 },
	{ title: '出発場所', align: 'center', key: 'departure_location', minWidth: 110 },
	{ title: '目的地', align: 'center', key: 'arrival_location', minWidth: 110 },
];

// バリデーション一覧
const validDatePattern = /^[0-9\-\/ :]*$/;
const validNumberPattern = /[0-9０-９]+$/;
const validTimePattern = /^\d{4}[\/-]\d{2}[\/-]\d{2} \d{2}:\d{2}$/;
// バリデーションを判定する。
// カスタムバリデーション
const ArrivalAfterDepartureDateTime = () => {
	if (departure_datetime.value > arrival_datetime.value) {
		return false;
	}
	return true;
};
const ArrivalAfterDepartureDistance = () => {
	const departure = parseFloat(departure_distance.value);
	const arrival = parseFloat(arrival_distance.value);

	if (!isNaN(departure) && !isNaN(arrival)) {
		if (departure > arrival) {
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
		discarded_items.value = res.data.discarded_daily_logs;
		vehicles.value = res.data.vehicles;
	}).catch(error => {
		console.error(error);
	});
};

fetchDailyLogs();

const onChangeVehicleSelect = (value) => {
	let v = value.vehicle_id
	current_vehicle_id.value = v
	console.log("current_vechicleのvalue:" + current_vehicle_id.value)
	return departure_distance.value = value.vehicle_current_drive_distance;
};

const editItem = async (id) => {
	const item = items.value.find(item => item.id === id)
	editedIndex.value = items.value.indexOf(item)
	vehicle_id.value = item.vehicle_id
	current_vehicle_id.value = item.vehicle_id
	vehicle_current_drive_distance.value = item.vehicle_current_drive_distance
	console.log(current_vehicle_id.value)
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
	user_id.value = item.user_id
	console.log(item.vehicle_id)
	// let vid = item.vehicle_id
	// isEditing.value = true
	dialog.value = true
}

// 編集(update) daily_logをupdateする。
const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
const updateItem = async () => {
	try {
		console.log("item_id:!" + current_vehicle_id.value)
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
				user_id: user_id.value,
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
		// window.location.reload();
		// formErrors.value = {};
		// departure_datetime.value = '';
		// arrival_datetime.value = '';
		// departure_distance.value = '';
		// arrival_distance.value = '';
		// departure_location.value = '';
		// arrival_location.value = '';
		// note.value = '';
		// vehicle_id.value = '';
		// is_alcohol_check.value = '';
		// is_studless_tire.value = '';
		// user_id.value = 0;
		// isEditing.value = false


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
function undeleteItem(item) {
	item_id.value = item.id
	dialogUndelete.value = true
}
function destroyItem(item) {
	item_id.value = item.id
	dialogDestroy.value = true
}

const deleteItemConfirm = async () => {
	try {
		const res = await fetch(`${API_URL}delete/${item_id.value}`, {
			method: 'PATCH',
			headers: {
				'Content-Type': 'application/json',
				'X-CSRF-Token': csrfToken
			},
			body: JSON.stringify({
				discarded_at: discarded_at.value,
			})
		});
		// 失敗した場合の処理
		if (!res.ok) {
			const errorData = await res.json(); // エラーレスポンスの内容を取得
			console.error('Error Response:', errorData); // エラーレスポンスをコンソールに表示
			formErrors.value = errorData.errors || {};
			console.error('フォームエラー:', JSON.stringify(toRaw(formErrors.value), null, 2));
			if (!isValid.value) {
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
		discarded_items.value.push(data);
		items.value = items.value.filter(item => item.id !== item_id.value)
		dialogDelete.value = false


	} catch (err) {
		console.error('Error:', err.message); // エラー情報をコンソールに表示
		console.log("エラー内容：" + formErrors.value)
		if (!isValid.value) {
			dialogError.value = true;
		}
	}
}

const undeleteItemConfirm = async () => {
	try {
		const res = await fetch(`${API_URL}undelete/${item_id.value}`, {
			method: 'PATCH',
			headers: {
				'Content-Type': 'application/json',
				'X-CSRF-Token': csrfToken
			},
			body: JSON.stringify({
				discarded_at: discarded_at.value,
			})
		});
		// 失敗した場合の処理
		if (!res.ok) {
			const errorData = await res.json(); // エラーレスポンスの内容を取得
			console.error('Error Response:', errorData); // エラーレスポンスをコンソールに表示
			formErrors.value = errorData.errors || {};
			console.error('フォームエラー:', JSON.stringify(toRaw(formErrors.value), null, 2));
			if (!isValid.value) {
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
		items.value.push(data);
		discarded_items.value = discarded_items.value.filter(item => item.id !== item_id.value)
		dialogUndelete.value = false

	} catch (err) {
		console.error('Error:', err.message); // エラー情報をコンソールに表示
		console.error('フォームエラー:', JSON.stringify(toRaw(formErrors.value), null, 2));
		if (!isValid.value) {
			dialogError.value = true;
		}
	}
}
const destroyItemConfirm = async (id) => {
	await fetch(`${API_URL}${id}`, {
		method: 'DELETE',
		headers: { 'X-CSRF-Token': csrfToken }
	})
	discarded_items.value = discarded_items.value.filter(item => item.id !== id)
	dialogDestroy.value = false
}

function close() {
	dialog.value = false
	nextTick(() => {
		editedIndex.value = -1
	})
}
function closeNotice() {
	dialogNotice.value = false
	localStorage.setItem('change', 'false');
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
function closeDestroy() {
	dialogDestroy.value = false
	nextTick(() => {
		editedIndex.value = -1
	})
}
function closeUndelete() {
	dialogUndelete.value = false
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
		updateItem();
	} else {
		// createItem();
	}
	if (!isValid) {
		close()
	}
}

// ダイアログが閉じられたときの動作。
watch(dialog, val => {
	val || close()
})
watch(dialogNotice, val => {
	val || closeNotice()
})
watch(dialogDelete, val => {
	val || closeDelete()
})
watch(dialogDestroy, val => {
	val || closeDestroy()
})
watch(dialogUndelete, val => {
	val || closeUndelete()
})
watch(dialogError, val => {
	val || closeError()
})
</script>
<style lang="css">
.discarded-index-check-box .v-label {
	font-size: 0.95rem;
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
	div.card-action {
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
