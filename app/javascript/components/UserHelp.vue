<template lang="">
    <v-app>
        <v-locale-provider locale="ja">
            <!-- <Header /> -->
            <UserHelp />
        </v-locale-provider>
    </v-app>
</template>
<script>
    import UserHelp from './help/UserHelp.vue'
    import Header from './Header.vue'
    export default {
        components: {
            UserHelp,
            Header,
        }
    }
</script>
<style lang="">

</style>