<template lang="" id="app">
    <v-app>
        <v-locale-provider locale="ja">
            <!-- <Test /> -->
            <Index />
        </v-locale-provider>
    </v-app>
</template>
<script>
    import Index from './daily_logs_for_admin/IndexForAdmin.vue'
    export default {
        components: {
            Index,
        }
    }
</script>
<style lang="">
</style>