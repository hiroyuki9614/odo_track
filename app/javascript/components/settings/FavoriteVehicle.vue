<template lang="">
	<section class="favorite-vehicle">
		<div class="bg-image h-100">
			<!-- 検索フォーム -->
			<!-- テーブル要素 -->
			<v-layout v-resize="onResize" column>
				<v-data-table v-model:expanded="expanded" :headers="headers" :items="items">
					<!-- テーブルタイトル -->
					<template v-slot:top>
						<v-toolbar flat>
							<v-toolbar-title class="table-title mobile">登録した車両一覧</v-toolbar-title>
							<v-dialog v-model="dialog" max-width="1000px">
								<template v-slot:activator="{ props }">
									<v-divider class="mx-4" inset vertical></v-divider>
									<v-btn color="primary" dark class="" v-bind="props" @click="initialRegistrationData"> 登録する </v-btn>
								</template>
								<!-- 新規作成ダイアログの内容 -->
								<v-card class="pt-5">
									<!-- <v-form fast-fail @submit.prevent> -->
									<v-form ref="form">
										<v-card-title>
											<span class="text-h5 ms-5">{{ formTitle }}</span>
										</v-card-title>
										<v-card-text class="card-text">
											<v-container>
												<v-row>
													<!-- フォームの内容 -->
													<v-col cols="12" md="6">
														<v-select v-model="id" label="車両" :items="vehicles" item-title="vehicle_name_and_number" item-value="id" @update:modelValue="onChangeVehicleSelect" persistent-hint return-object single-line :rules="vehicleRules"></v-select>
													</v-col>
													<v-col cols="12" md="6">
														<v-textarea v-model="favorite_vehicle_note" label="備考" variant="filled" row-height="100" :rules="favoriteVehicleNoteRules" class="form-note" />
													</v-col>
												</v-row>
											</v-container>
										</v-card-text>
										<!-- 新規作成ダイアログのボタン -->
										<v-card-actions class="card-action fv-card-action">
											<v-spacer></v-spacer>
											<v-btn color="blue-darken-1" variant="text" @click="close"> 取り消し </v-btn>
											<v-btn color="blue-darken-1" variant="text" type="submit" @click="save"> 保存 </v-btn>
										</v-card-actions>
									</v-form>
								</v-card>
							</v-dialog>
							<!-- 削除ダイアログ -->
							<v-dialog v-model="dialogDelete" max-width="600px">
								<v-card>
									<v-card-title class="body-2 text-center">この車両の登録を解除します。</v-card-title>
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
									<v-card-actions id="favorite-vehicles">
										<v-spacer></v-spacer>
										<v-btn color="blue-darken-1" variant="text" @click="closeError">閉じる</v-btn>
										<v-spacer></v-spacer>
									</v-card-actions>
								</v-card>
							</v-dialog>
						</v-toolbar>
					</template>
					<!-- テーブルの拡張 -->
					<template v-slot:item.actions="{ columns, item, index }">
						<div class="flex-container">
							<!-- アイコン -->
							<div class="table-icons">
								<v-tooltip v-model="deleteShow[index]" location="top">
									<template v-slot:activator="{ props }">
										<v-icon @mouseenter="deleteShow[index] = true" @mouseleave="deleteShow[index] = false" size="small" color="error" v-bind="props" @click="deleteItem(item)" class="delete-icon"> mdi-delete </v-icon>
									</template>
									<span>削除</span>
								</v-tooltip>
							</div>
						</div>
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
const id = ref();
const user_id = ref('');
const vehicle_id = ref('');
const favorite_vehicle_note = ref('');
const vehicle_name = ref('');
const vehicle_number = ref('');
const vehicles = ref('');
const current_vehicle_id = ref('');
const formErrors = ref({});
const newFavoriteVehicles = ref([]);
const items = ref([]);
const item_id = ref(0);
const isMobile = ref(false);

const onChangeVehicleSelect = (value) => {
	let v = value.id
	vehicle_id.value = v
	return;
};

const onResize = () => {
  if (window.innerWidth < 600)
    return isMobile.value = true;
  else
    return isMobile.value = false;
}

const editedIndex = ref(-1);
const expanded = ref([]);
const API_URL = `/api/favorite_vehicles/`;
// const isEditing = ref(false)
const errors = ref('');

// indexテーブルのヘッダー定義
const headers = [
	{ title: '車両名称', align: 'center', key: 'vehicle_name', width: '200px' },
	{ title: 'ナンバー', align: 'center', key: 'vehicle_number', width: '200px' },
	{ title: 'メモ', align: 'center', key: 'favorite_vehicle_note', width: 'auto' },
	{ title: '', key: 'actions', sortable: false },
];

// バリデーション一覧
const isValid = () => {
	if (vehicleIsValid.value && favoriteVehicleNoteIsValid.value) {
		return true;
	} else {
		return false;
	}
};

const vehicleIsValid = ref(true);
const vehicleRules = [
	(value) => {
		if (!value) {
			vehicleIsValid.value = false;
			return '車両を選択して下さい。';
		}
		// items.
		if (items.value.some(item => item.vehicle_id === value.id)) {
			vehicleIsValid.value = false;
			return 'その車両は登録済です。';
		}
		vehicleIsValid.value = true;
		return true;
	},
];
const favoriteVehicleNoteIsValid = ref(true);
const favoriteVehicleNoteRules = [
	(value) => {
		if (value > 200) {
			favoriteVehicleNoteIsValid.value = false;
			return '200文字以内で入力して下さい。';
		}
		favoriteVehicleNoteIsValid.value = true;
		return true;
	},
];

// 編集中のアイテムが新規アイテムか既存アイテムかに基づいて、フォームのタイトルを動的に計算する。
const formTitle = computed(() => {
	return editedIndex.value === -1 ? '車両を登録する' : '登録した車両を編集する';
});

const props = computed(() => {
	return {
		label: 'Switch',
		inset: model.value === 'inset' || undefined,
		indeterminate: indeterminate.value || undefined,
	};
});

// daily_logs_controllerからJSONを取得(index)
const fetchFavoriteVehicles = () => {
	const url = API_URL;
	axios
		.get(url)
		.then((res) => {
			items.value = res.data.favorite_vehicles;
			vehicles.value = res.data.vehicles
		})
		.catch((error) => {
			console.error(error);
		});
};

// fetchFavoriteVehiclesを初期化
fetchFavoriteVehicles();

// 登録の際にフォームのデータを空にする。
const initialRegistrationData = () => {
	vehicle_id.value = '',
		favorite_vehicle_note.value = ''
	return;
};

// 投稿(create) daily_logを作成する。
const createItem = async () => {
	try {
		const res = await fetch(API_URL, {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
			},
			body: JSON.stringify({
				vehicle_id: vehicle_id.value,
				favorite_vehicle_note: favorite_vehicle_note.value,
			}),
		});
		// 失敗した場合の処理
		if (!res.ok) {
			const errorData = await res.json(); // エラーレスポンスの内容を取得
			console.error('Error Response:', errorData); // エラーレスポンスをコンソールに表示
			formErrors.value = errorData.errors || {};
			if (isValid.value) {
				return (dialogError.value = true);
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
	} catch (err) {
		console.error('Error:', err.message); // エラー情報をコンソールに表示
		console.log('エラー内容：' + formErrors.value);
		if (isValid.value) {
			dialogError.value = true;
		}
	}
};

function deleteItem(item) {
	item_id.value = item.id;
	dialogDelete.value = true;
}
const deleteItemConfirm = async (id) => {
	await fetch(`${API_URL}${id}`, {
		method: 'DELETE',
	});
	items.value = items.value.filter((item) => item.id !== id);
	dialogDelete.value = false;
};

function close() {
	dialog.value = false;
	nextTick(() => {
		editedIndex.value = -1;
	});
}
function closeDelete() {
	dialogDelete.value = false;
	nextTick(() => {
		editedIndex.value = -1;
	});
}
function closeError() {
	dialogError.value = false;
	nextTick(() => {
		editedIndex.value = -1;
	});
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
watch(dialog, (val) => {
	val || close();
});
watch(dialogDelete, (val) => {
	val || closeDelete();
});
watch(dialogError, (val) => {
	val || closeError();
});
</script>
<style lang="css">
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
	div.fv-card-action {
		margin-top: 10px;
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
