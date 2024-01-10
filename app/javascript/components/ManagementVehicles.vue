<template lang="">
    <v-app>
        <v-locale-provider locale="ja">
            <!-- <Test /> -->
            <Index />
        </v-locale-provider>
    </v-app>
</template>
<script>
    import Index from './vehicles/VehicleIndex.vue'
    export default {
        components: {
            Index
        }
    }
</script>
<style lang="">

</style>