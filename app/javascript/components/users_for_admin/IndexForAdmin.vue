<template lang="">
	<section class="vehicle_index">
			<!-- ================================== -->
        <!-- ここから論理削除した社員のテーブル -->
        <!-- ================================== -->
			<div v-if="discardedUsersIndex">
        <!-- 検索フォーム -->
        <v-layout v-resize="onResize" column>
				<v-data-table :search="search" :headers="headers" :items="discarded_items" style="background-color: white">
					<!-- テーブルタイトル -->
					<template v-slot:top>
						<v-toolbar flat>
							<div v-if="!isMobile" style="display: flex; align-items: center;">
								<v-toolbar-title class="table-title">社員一覧</v-toolbar-title>
								<v-divider class="mx-4" inset vertical></v-divider>
							</div>
							<v-checkbox v-model="discardedUsersIndex" :label="`削除した社員情報を表示する`" class="discarded-index-check-box" style="display: flex; justify-content: end; font-size: x-small" />
							<v-divider class="mx-4" inset vertical></v-divider>
							<div class="search-field">
								<v-text-field v-model="search" label="検索" single-line hide-details class="search-form" density="compact" />
							</div>
							<v-divider class="mx-4" inset vertical></v-divider>
							<v-dialog v-model="dialog" max-width="1000px">
								<!-- 新規作成ダイアログの内容 -->
								<v-card class="pt-5">
									<!-- <v-form fast-fail @submit.prevent> -->
								</v-card>
							</v-dialog>
							<!-- 削除取消ダイアログ -->
							<v-dialog v-model="dialogUndelete" max-width="500px">
								<v-card>
									<v-card-title class="text-center">この社員の削除を取消しますか？</v-card-title>
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
        <!-- ここから通常の社員のテーブル       -->
        <!-- ================================== -->
			<div v-else>
        <v-layout v-resize="onResize" column>
				<v-data-table :search="search" :headers="headers" :items="items" style="background-color: white">
					<!-- テーブルタイトル -->
            <template v-slot:top>
						<v-toolbar flat>
							<div v-if="!isMobile" style="display: flex; align-items: center;">
								<v-toolbar-title class="table-title">社員一覧</v-toolbar-title>
								<v-divider class="mx-4" inset vertical></v-divider>
							</div>
							<v-checkbox v-model="discardedUsersIndex" :label="`削除した社員情報を表示する`" class="discarded-index-check-box" style="display: flex; justify-content: end; font-size: x-small" />
							<v-divider class="mx-4" inset vertical></v-divider>
							<div class="search-field">
								<v-text-field v-model="search" label="検索" single-line hide-details class="search-form" density="compact" />
							</div>
                <v-divider class="mx-4" inset vertical></v-divider>
							<v-dialog v-model="dialog" max-width="800px">
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
													<v-col cols="12" sm="6" md="4">
														<v-text-field v-model="user_name" label="氏名" :rules="userNameRules" />
													</v-col>
													<v-col cols="12" sm="6" md="4">
														<v-text-field v-model="email" required label="メールアドレス" :rules="emailRules" />
													</v-col>
													<v-col cols="12" sm="6" md="4">
														<v-text-field v-model="telephone" required label="電話番号" :rules="telephoneRules" />
                              <v-switch color="primary" v-model="admin" label="管理者権限" style="float: right;"></v-switch>
													</v-col>
                          </v-row>
											</v-container>
										</v-card-text>
										<!-- 新規作成/編集ダイアログのボタン -->
										<v-card-actions class="user-card-action">
											<v-spacer></v-spacer>
											<v-btn color="blue-darken-1" variant="text" @click="close"> 取り消し </v-btn>
											<v-btn color="blue-darken-1" :loading="loading" variant="text" type="submit" @click="save"> 保存 </v-btn>
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
									<v-card-title class="text-center">この社員情報を除外してもよろしいでしょうか？</v-card-title>
									<p class="text-center" style="margin-bottom: 0px">この社員情報は一覧に表示されなくなります。</p>
									<p class="text-center text-body-2" style="margin-top: 0px">(関連付けられた日報は削除されません)</p>
									<v-card-actions>
										<v-spacer></v-spacer>
										<v-btn color="blue-darken-1" variant="text" @click="closeDelete">Cancel</v-btn>
										<v-btn type="submit" color="blue-darken-1" @click="deleteItemConfirm(item_id)">OK</v-btn>
										<v-spacer></v-spacer>
									</v-card-actions>
								</v-card>
							</v-dialog>
                <v-dialog v-model="dialogDestroy" max-width="500px">
								<v-card>
									<v-card-title class="text-center">この社員情報を削除してもよろしいでしょうか？</v-card-title>
									<p class="text-center" style="margin-bottom: 0px">この社員情報は完全に削除されます。</p>
									<v-card-actions>
										<v-spacer></v-spacer>
										<v-btn color="blue-darken-1" variant="text" @click="closeDestroy">Cancel</v-btn>
										<v-btn type="submit" color="blue-darken-1" @click="destroyItemConfirm(item_id)">OK</v-btn>
										<v-spacer></v-spacer>
									</v-card-actions>
								</v-card>
							</v-dialog>
              </v-toolbar>
            </template>
					<!-- アイコン -->
					<template v-slot:item.actions="{ columns, item, index}">
              <div v-if="item.confirmed_at == '認証済' ">
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
              </div>
            <div v-else>
              <v-tooltip v-model="deleteShow[index]" location="top">
							<template v-slot:activator="{ props }">
								<v-icon @mouseenter="deleteShow[index] = true" @mouseleave="deleteShow[index] = false" size="small" color="error" v-bind="props" @click="destroyItem(item)" class="delete-icon"> mdi-delete </v-icon>
							</template>
							<span>削除する</span>
						</v-tooltip>
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
const dialogNotice = ref(false);
const changeEmail = localStorage.getItem("change");
const dialogDelete = ref(false);
const dialogDestroy = ref(false);
const dialogUndelete = ref(false);
const dialogError = ref(false);

const editShow = ref({});
const deleteShow = ref({});
const undeleteShow = ref({});
const search = ref('');
const form = ref();
// Userモデルの項目
const created_at = ref('');
const user_name = ref('');
const email = ref('');
const current_email = ref('');
const telephone = ref('');
const confirmed_at = ref('');
const discarded_at = ref('');
const admin = ref(false);
const isMobile = ref(false);

const items = ref([]);
const item_id = ref(0)
const discarded_items = ref([]);

const formErrors = ref({});
const discardedUsersIndex = ref(false);
const editedIndex = ref(-1);

const API_URL = `/api/users_for_admin/`;

const onResize = () => {
  if (window.innerWidth < 600)
    return isMobile.value = true;
  else
    return isMobile.value = false;
}

// indexテーブルのヘッダー定義
const headers = [
    { title: '登録日時', align: 'center', key: 'created_at', minWidth: 110 },
    { title: '社員名称', align: 'center', key: 'user_name', minWidth: 110 },
    { title: 'メールアドレス', align: 'center', key: 'email', minWidth: 160 },
    { title: '電話番号', align: 'center', key: 'telephone', minWidth: 110 },
    { title: '認証状況', align: 'center', key: 'confirmed_at', minWidth: 110 },
    { title: '', key: 'actions', sortable: false, minWidth: 110 },
];

// バリデーション一覧
// 数字のみ
const validNumberPattern = /[0-9]+$/;
// メールアドレスのバリデーション
const validEmailPattern = /^[A-Za-z0-9]{1}[A-Za-z0-9_.-]*@{1}[A-Za-z0-9_.-]+.[A-Za-z0-9]+$/;
// バリデーションを判定する。
const isValid = () => {
  if(userNameIsValid.value && emailIsValid.value && telephoneIsValid.value)
  {
    return true;
  } else {
    return false;
  }
};
// カスタムバリデーション
const userNameIsValid = ref(true);
const userNameRules = [
value => {
    if (!value) {
      userNameIsValid.value = false;
      return '氏名を入力して下さい。';
    }
    if (value.length > 50){
      userNameIsValid.value = false;
      return '50文字以内で入力して下さい。'
    }
    userNameIsValid.value = true;
  return true;
  }
];
const emailIsValid = ref(true);
const emailRules = [
  value => {
    if (!value) {
      emailIsValid.value = false;
      return 'メールアドレスを入力して下さい。';
    }
    if (value.length > 254){
      emailIsValid.value = false;
      return '254文字以内で入力して下さい。'
    }
    if (!validEmailPattern.test(value)){
      emailIsValid.value = false;
      return '形式が不正です。 正しく入力してください。';
    }
    emailIsValid.value = true;
    return true;
  }
];
const telephoneIsValid = ref(true);
const telephoneRules = [
  value => {
    if(!value){
      telephoneIsValid.value = false;
      return '電話番号を入力して下さい。';
    }
    if (!validNumberPattern.test(value)){
      telephoneIsValid.value = false;
      return '無効な形式です。半角数字のみ使用できます。';
    }
    if (value.length < 10){
      telephoneIsValid.value = false;
      return '10文字以上で入力して下さい。';
    }
  if (value.length > 11){
      telephoneIsValid.value = false;
      return '11文字以内で入力して下さい。';
    }
    telephoneIsValid.value = true;
    return true;
  }
];

// 編集中のアイテムが新規アイテムか既存アイテムかに基づいて、フォームのタイトルを動的に計算する。
const formTitle = computed(() => {
  return editedIndex.value === -1 ? '社員を登録する' : '社員情報を編集する';
});

const props = computed(() => {
    return {
      label: 'Switch',
      inset: model.value === 'inset' || undefined,
      indeterminate: indeterminate.value || undefined,
    }
  })

// vehicle modelからJSONを取得(index)
const fetchUsers = () => {
    const url = API_URL;
    axios.get(url).then(res => {
        items.value = res.data.users;
        discarded_items.value = res.data.discarded_users;
    }).catch(error => {
        console.error(error);
    });
};

// fetchVehiclesを初期化
fetchUsers();

const editItem = async(id) => {
  const item = items.value.find(item => item.id === id)
  editedIndex.value = items.value.indexOf(item)
  user_name.value = item.user_name
  current_email.value = email.value = item.email
  telephone.value = item.telephone
  item_id.value = item.id
  admin.value = item.admin
console.log("")
  dialog.value = true
}

const aaa = ref('');

// 編集(update) vehicleをupdateする。
const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
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
        user_name: user_name.value,
        email: email.value,
        telephone: telephone.value,
        admin: admin.value
      })
    });
    if (!res.ok) {
      const errorData = await res.json(); // エラーレスポンスの内容を取得
      console.error('Error Response:', errorData); // エラーレスポンスをコンソールに表示
      formErrors.value = errorData.errors || {};
      console.error('フォームエラー:', JSON.stringify(toRaw(formErrors.value), null, 2));
      if(!isValid.value){
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
    console.error('フォームエラー:', JSON.stringify(toRaw(formErrors.value), null, 2));
    if(email.value != current_email.value) {
      alert("【メールアドレスの変更について】\n\nメールアドレスを変更後、メールが送信されます。\nメール本文内のURLから認証が必要となります。\n\n認証完了後にメールアドレスは変更されます。")
    }
  }
}

function deleteItem (item) {
    item_id.value = item.id
    dialogDelete.value = true
  }
  function undeleteItem (item) {
    item_id.value = item.id
    dialogUndelete.value = true
  }
  function destroyItem (item) {
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
      if(!isValid.value){
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
    if(!isValid.value){
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
      if(!isValid.value){
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
    if(!isValid.value){
        dialogError.value = true;
      }
  }
}
const destroyItemConfirm = async(id) => {
        await fetch (`${API_URL}${id}`, {
            method: 'DELETE',
            headers: { 'X-CSRF-Token': csrfToken }
        })
        items.value = items.value.filter(item => item.id !== id)
        dialogDestroy.value = false
    }

function close () {
  dialog.value = false
  nextTick(() => {
    editedIndex.value = -1
  })
}
function closeNotice () {
  dialogNotice.value = false
  localStorage.setItem('change', 'false');
  nextTick(() => {
    editedIndex.value = -1
  })
}
function closeDelete () {
  dialogDelete.value = false
  nextTick(() => {
    editedIndex.value = -1
  })
}
function closeDestroy () {
  dialogDelete.value = false
  nextTick(() => {
    editedIndex.value = -1
  })
}
function closeUndelete () {
  dialogUndelete.value = false
  nextTick(() => {
    editedIndex.value = -1
  })
}
function closeError () {
  dialogError.value = false
  nextTick(() => {
    editedIndex.value = -1
  })
}
function save () {
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
.discarded-index-check-box .v-label{
  font-size: 0.95rem;
}
.flex-container {
    display: flex;
}
.expanded-value {
  display: flex;
    justify-content: auto; /* 要素間のスペースを均等に分配 */
    align-items: center; /* 要素を垂直方向の中央に配置 */
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
.note{
    width: 200px; /* 幅の設定 */
	max-height: 100px; /* 最大高さの設定 */
	overflow: auto; /* 高さが最大値を超えた場合にスクロールバーを表示 */
	word-break: break-word; /* 単語の途中でも折り返しを許可 */
    padding-top: 15px;
}
.search-field{
  width: 200px;
  margin: auto;
  display: flex;        /* フレックスボックスを有効化 */
  align-items: center;  /* アイテムを垂直方向の中央に配置 */
  justify-content: center; /* アイテムを水平方向の中央に配置 */
}

.table-title{
  padding-left: 20px;
}
.card-text{
  /* background-color: black; */
  max-height: 270px;
}
@media screen and (max-width: 768px) {
  div.user-card-action{
    margin-top: 100px;
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
