<template lang="">
	<section class="vehicle_index">
		<div class="bg-image h-100">
			<!-- ================================== -->
			<!-- ここから論理削除した車両のテーブル -->
			<!-- ================================== -->
			<div v-if="discardedVehiclesIndex">
				<v-layout v-resize="onResize" column>
					<!-- 検索フォーム -->
					<v-data-table :search="search" :headers="headers" :items="discarded_items" style="background-color: white">
						<!-- テーブルタイトル -->
						<template v-slot:top>
							<v-toolbar flat>
								<div v-if="!isMobile" style="display: flex; align-items: center">
									<v-toolbar-title class="table-title">車両一覧</v-toolbar-title>
									<v-divider class="mx-4" inset vertical></v-divider>
								</div>
								<v-checkbox v-model="discardedVehiclesIndex" :label="`削除した車両を表示する`" class="discarded-index-check-box" style="display: flex; justify-content: end; font-size: x-small" />
								<!-- <v-divider class="mx-4" inset vertical></v-divider> -->
								<!-- <div class="search-field">
									<v-text-field v-model="search" label="検索" single-line hide-details class="search-form" density="compact" />
								</div> -->
								<v-divider class="mx-4" inset vertical></v-divider>
								<v-dialog v-model="dialog" max-width="1000px">
									<template v-slot:activator="{ props }">
										<v-btn color="primary" dark class="" v-bind="props" @click="initialData">車両を登録</v-btn>
									</template>
									<!-- 新規作成ダイアログの内容 -->
									<v-card class="pt-5">
										<!-- <v-form fast-fail @submit.prevent> -->
										<v-form ref="form">
											<v-card-title>
												<span class="text-h6 ms-5">{{ formTitle }}</span>
											</v-card-title>
											<v-card-text class="card-text">
												<v-container>
													<v-row>
														<!-- フォームの内容 -->
														<v-col cols="12" sm="6" md="3">
															<v-text-field v-model="vehicle_name" label="車両名称" :rules="vehicleNameRules" />
														</v-col>
														<v-col cols="12" sm="6" md="3">
															<v-text-field v-model="number" required label="ナンバー(4桁ハイフン不要)" :rules="numberRules" />
														</v-col>
														<v-col cols="12" sm="6" md="3">
															<v-text-field v-model="manufacture" required label="メーカー" :rules="manufactureRules" />
														</v-col>
														<v-col cols="12" sm="6" md="3">
															<div v-if="editedIndex == -1">
																<v-text-field v-model="current_drive_distance" item-value="manufacture" required label="現在の走行距離(任意)" :rules="currentDriveDistanceRules" />
															</div>
															<div v-else>
																<v-text-field v-model="current_drive_distance" item-value="manufacture" required disabled label="現在の走行距離(任意)" :rules="currentDriveDistanceRules" />
															</div>
														</v-col>
													</v-row>
												</v-container>
											</v-card-text>
											<!-- 新規作成/編集ダイアログのボタン -->
											<v-card-actions class="card-action vc-card-action">
												<v-spacer></v-spacer>
												<v-btn color="blue-darken-1" variant="text" @click="close"> 取り消し </v-btn>
												<v-btn color="blue-darken-1" variant="text" type="submit" @click="save"> 保存 </v-btn>
											</v-card-actions>
										</v-form>
									</v-card>
								</v-dialog>
								<!-- 削除ダイアログ -->
								<v-dialog v-model="dialogUndelete" max-width="500px">
									<v-card>
										<v-card-title class="text-center">この車両の削除を取消しますか？</v-card-title>
										<v-card-actions>
											<v-spacer></v-spacer>
											<v-btn color="blue-darken-1" variant="text" @click="closeUndelete">Cancel</v-btn>
											<v-btn type="submit" color="blue-darken-1" @click="undeleteItemConfirm(item_id)">OK</v-btn>
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
						<template v-slot:item.actions="{ columns, item, index}">
							<v-tooltip v-model="undeleteShow[index]" location="top">
								<template v-slot:activator="{ props }">
									<v-icon @mouseenter="undeleteShow[index] = true" @mouseleave="undeleteShow[index] = false" size="small" color="green" v-bind="props" @click="undeleteItem(item)" class="delete-icon"> mdi-undo </v-icon>
								</template>
								<span>取消</span>
							</v-tooltip>
						</template>
					</v-data-table>
				</v-layout>
			</div>
			<!-- ================================== -->
			<!-- ここから通常の車両のテーブル						 -->
			<!-- ================================== -->
			<div v-else>
				<v-layout v-resize="onResize" column>
					<!-- 検索フォーム -->
					<v-data-table :search="search" :headers="headers" :items="items" style="background-color: white">
						<!-- テーブルタイトル -->
						<template v-slot:top>
							<v-toolbar flat>
								<div v-if="!isMobile" style="display: flex; align-items: center">
									<v-toolbar-title class="table-title">運転日報</v-toolbar-title>
									<v-divider class="mx-4" inset vertical></v-divider>
								</div>
								<v-checkbox v-model="discardedVehiclesIndex" :label="`削除した車両を表示する`" class="discarded-index-check-box" style="display: flex; justify-content: end; font-size: x-small" />
								<!-- <v-divider class="mx-4" inset vertical></v-divider>
								<div class="search-field">
									<v-text-field v-model="search" label="検索" single-line hide-details class="search-form" density="compact" />
								</div> -->
								<v-divider class="mx-4" inset vertical></v-divider>
								<v-dialog v-model="dialog" max-width="1000px">
									<template v-slot:activator="{ props }">
										<v-btn color="primary" dark class="" v-bind="props" @click="initialData">車両を登録</v-btn>
									</template>
									<!-- 新規作成ダイアログの内容 -->
									<v-card class="pt-5">
										<!-- <v-form fast-fail @submit.prevent> -->
										<v-form ref="form">
											<v-card-title v-if="isMobile">
												<span class="text-h6 ms-5">{{ formTitle }}</span>
											</v-card-title>
											<v-card-text class="card-text">
												<v-container>
													<v-row>
														<!-- フォームの内容 -->
														<v-col cols="12" sm="6" md="3">
															<v-text-field v-model="vehicle_name" label="車両名称" :rules="vehicleNameRules" />
														</v-col>
														<v-col cols="12" sm="6" md="3">
															<v-text-field v-model="number" required label="ナンバー(4桁ハイフン不要)" :rules="numberRules" />
														</v-col>
														<v-col cols="12" sm="6" md="3">
															<v-text-field v-model="manufacture" required label="メーカー" :rules="manufactureRules" />
														</v-col>
														<v-col cols="12" sm="6" md="3">
															<div v-if="editedIndex == -1">
																<v-text-field v-model="current_drive_distance" item-value="manufacture" required label="現在の走行距離(任意)" :rules="currentDriveDistanceRules" />
															</div>
															<div v-else>
																<v-text-field v-model="current_drive_distance" item-value="manufacture" required disabled label="現在の走行距離(任意)" :rules="currentDriveDistanceRules" />
															</div>
														</v-col>
													</v-row>
												</v-container>
											</v-card-text>
											<!-- 新規作成/編集ダイアログのボタン -->
											<v-card-actions class="card-action vc-card-action">
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
										<v-card-title class="text-center">この車両を除外してもよろしいでしょうか？</v-card-title>
										<p class="text-center" style="margin-bottom: 0px">この車両は一覧に表示されなくなります</p>
										<p class="text-center text-body-2" style="margin-top: 0px">(関連付けられた日報は削除されません)</p>
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
						<template v-slot:item.actions="{ columns, item, index}">
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
								<span>除外する</span>
							</v-tooltip>
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
const dialogDelete = ref(false);
const dialogUndelete = ref(false);
const dialogError = ref(false);

const editShow = ref({});
const deleteShow = ref({});
const undeleteShow = ref({});
const search = ref('');
const form = ref();
const vehicle_name = ref('');
const number = ref('');
const manufacture = ref('');
const current_drive_distance = ref('');
const discarded_at = ref('');
const formErrors = ref({});
const items = ref([]);
const discarded_items = ref([]);
const item_id = ref(0)
const discardedVehiclesIndex = ref(false);
const isMobile = ref(false);

const editedIndex = ref(-1);
const API_URL = `/api/management_vehicles/`;

const onResize = () => {
	if (window.innerWidth < 600)
		return isMobile.value = true;
	else
		return isMobile.value = false;
}

// post時に空文字を送信するとERRORになるので空文字を0に変換する。
const format_current_drive_distance = () => {
	if (!current_drive_distance.value)

		return current_drive_distance.value || 0;
};

// indexテーブルのヘッダー定義
const headers = [
	{ title: '登録日時', align: 'center', key: 'created_at', minWidth: '110px' },
	{ title: '車両名称', align: 'center', key: 'vehicle_name', minWidth: '110px' },
	{ title: 'ナンバー', align: 'center', key: 'number',  minWidth: '110px' },
	{ title: 'メーカー', align: 'center', key: 'manufacture',  minWidth: '110px' },
	{ title: '現在の走行距離', align: 'center', key: 'current_drive_distance',  minWidth: '110px' },
	{ title: '', key: 'actions', sortable: false,  minWidth: '110px' },
];

// バリデーション一覧
// 0-9とカンマのみ
const validDatePattern = /^[0-9\,\/]*$/;
// 数字のみ
const validNumberPattern = /[0-9]+$/;
// バリデーションを判定する。
const isValid = () => {
	if (vehicleNameIsValid.value && currentDriveDistanceIsValid.value && numberIsValid.value && manufactureIsValid.value) {
		return true;
	} else {
		return false;
	}
};
// カスタムバリデーション
const vehicleNameIsValid = ref(true);
const vehicleNameRules = [
	value => {
		if (!value) {
			vehicleNameIsValid.value = false;
			return '車両名称を入力して下さい。';
		}
		if (value.length > 20) {
			vehicleNameIsValid.value = false;
			return '20文字以内で入力して下さい。'
		}
		vehicleNameIsValid.value = true;
		return true;
	}
];
const currentDriveDistanceIsValid = ref(true);
const currentDriveDistanceRules = [
	value => {
		if (value.length > 10) {
			currentDriveDistanceIsValid.value = false;
			return '10文字以内で入力して下さい。'
		}
		if (!validDatePattern.test(value)) {
			currentDriveDistanceIsValid.value = false;
			return '数字とカンマのみ入力できます。(カンマは不要です)';
		}
		currentDriveDistanceIsValid.value = true;
		return true;
	}
];
const numberIsValid = ref(true);
const numberRules = [
	value => {
		if (!value) {
			numberIsValid.value = false;
			return 'ナンバーを入力して下さい。';
		}
		if (!validNumberPattern.test(value)) {
			numberIsValid.value = false;
			return '無効な形式です。半角数字のみ使用できます。';
		}
		if (value.length > 4) {
			numberIsValid.value = false;
			return '4文字以内で入力して下さい。';
		}
		numberIsValid.value = true;
		return true;
	}
];
const manufactureIsValid = ref(true);
const manufactureRules = [
	value => {
		if (!value) {
			manufactureIsValid.value = false;
			return 'メーカーを入力して下さい。';
		}
		if (value.length > 20) {
			manufactureIsValid.value = false;
			return '20文字以内で入力して下さい。';
		}
		manufactureIsValid.value = true;
		return true;
	}
];

// 編集中のアイテムが新規アイテムか既存アイテムかに基づいて、フォームのタイトルを動的に計算する。
const formTitle = computed(() => {
	return editedIndex.value === -1 ? '車両を登録する' : '車両情報を編集する';
});

const props = computed(() => {
	return {
		label: 'Switch',
		inset: model.value === 'inset' || undefined,
		indeterminate: indeterminate.value || undefined,
	}
})

// vehicle modelからJSONを取得(index)
const fetchVehicles = () => {
	const url = API_URL;
	axios.get(url).then(res => {

		items.value = res.data.vehicles;
		discarded_items.value = res.data.discarded_vehicles;
		console.log(res.data)
	}).catch(error => {
		console.error(error);
	});
};

// fetchVehiclesを初期化
fetchVehicles();

// 投稿(create) vehicleを作成する。
const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
const createItem = async () => {
	try {
		const res = await fetch(API_URL, {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
				'X-CSRF-Token': csrfToken
			},
			body: JSON.stringify({
				vehicle_name: vehicle_name.value,
				number: number.value,
				manufacture: manufacture.value,
				current_drive_distance: format_current_drive_distance(),
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
		console.log(data.current_drive_distance);
		items.value.push(data);

	} catch (err) {
		console.error('Error:', err.message); // エラー情報をコンソールに表示
		console.log("エラー内容：" + formErrors.value)
		if (isValid.value) {
			dialogError.value = true;
		}
	}
}

// 新規作成時にフォームのデータを削除する。
const initialData = () => {
	vehicle_name.value = '';
	number.value = '';
	manufacture.value = '';
	current_drive_distance.value = '';
};

const editItem = async (id) => {
	const item = items.value.find(item => item.id === id)
	editedIndex.value = items.value.indexOf(item)
	console.log(editedIndex.value)
	vehicle_name.value = item.vehicle_name
	number.value = item.number
	manufacture.value = item.manufacture
	current_drive_distance.value = item.current_drive_distance
	item_id.value = item.id
	dialog.value = true
}

// 編集(update) vehicleをupdateする。
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
				vehicle_name: vehicle_name.value,
				number: number.value,
				manufacture: manufacture.value,
				// current_drive_distance: current_drive_distance.value
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

		const index = items.value.findIndex(item => item.id === data.id)
		items.value[index] = data

	} catch (err) {
		console.error('Error:', err.message); // エラー情報をコンソールに表示
		console.log("エラー内容：" + formErrors.value)
		if (!isValid.value) {
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
		console.log("エラー内容：" + formErrors.value)
		if (!isValid.value) {
			dialogError.value = true;
		}
	}
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
function closeUndelete() {
	dialogUndelete.value = false
	nextTick(() => {
		editedIndex.value = -1
	})
}
function closeError() {editedIndex
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
		createItem();
	}
	if (!isValid) {
		close()
	}
}

// ダイアログが閉じられたときの動作。
watch(dialog, val => {
	val || close()
})
watch(dialogDelete, val => {
	val || closeDelete()
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
  div.vc-card-action{
    margin-top: 130px;
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
