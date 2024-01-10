<template lang="">
    <v-app>
        <v-locale-provider locale="ja">
            <!-- <Header /> -->
            <Index />
        </v-locale-provider>
    </v-app>
</template>
<script>
    import Index from './daily_logs/Index.vue'
    import Header from './Header.vue'
    export default {
        components: {
            Index,
            Header,
        }
    }
</script>
<style lang="">

</style>