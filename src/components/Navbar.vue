<template>
    <div>
      <b-navbar toggleable="lg" type="dark" variant="success">
        <b-container>
            
            <b-navbar-toggle target="nav-collapse"></b-navbar-toggle>
            <b-collapse id="nav-collapse" is-nav>
              <!-- Right aligned nav items -->
              <b-navbar-nav class="ml-auto">
                <b-nav-item-dropdown right v-if="account">
                  <!-- Using 'button-content' slot -->
                  <template slot="button-content"><em v-html="account"></em></template>
                  <b-dropdown-item href="#">Profile</b-dropdown-item>
                  <b-dropdown-item href="#">Sign Out</b-dropdown-item>
                </b-nav-item-dropdown>
              </b-navbar-nav>
            </b-collapse>
          </b-container>
      </b-navbar>
    </div>  
</template>
<script>

export default {
    props: ['account'],
    data() {
        return {
        }
    }   
}    
</script>