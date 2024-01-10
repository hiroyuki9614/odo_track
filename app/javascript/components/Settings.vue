<template lang="">
    <v-app>
        <v-locale-provider locale="ja">
            <!-- <Test /> -->
            <FavoriteVehicle />
        </v-locale-provider>
    </v-app>
</template>
<script>
    import FavoriteVehicle from './settings/FavoriteVehicle.vue'
    export default {
        components: {
            FavoriteVehicle
        }
    }
</script>
<style lang="">

</style>