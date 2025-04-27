<?php
/*
Plugin Name: AT - Custom Branding
Plugin URI: http://atd.digital
Update URI: https://raw.githubusercontent.com/amit-trabelsi-digital/at-branding-wp-plugin/main/plugin-info.json
Description: An internal plugin for adding custom branding to wordpress website.
Version: {{VERSION}}
Author: Amit Trabelsi
Author URI: http://atd.digital
Text Domain: at
*/

if( !defined( 'PLUGIN_MAIN_DIR' ) ) {
    define( 'PLUGIN_MAIN_DIR', plugin_dir_url( __FILE__ ) );
}

// כל שאר הקוד מהקובץ המקורי יישאר זהה
// אתה יכול להעתיק את כל הקוד מהקובץ המקורי לכאן

if( !class_exists( 'atBranding' ) ) {
    class atBranding {
        /**
         * @var string at main branding color.
         */
        public $atColor = "#4ec5e0";

        /**
         * @var string at main logo.
         */
        public $atLogo;

        /**
         * @var string at website url.
         */
        public $atURL = "http://atd.digital";

        /**
         * Perform the following actions on plugin instance initialization.
         */
        public function __construct() {
            $this->atLogo = PLUGIN_MAIN_DIR . 'assets/images/at-logo.png';
            $this->atAdminFavicon = PLUGIN_MAIN_DIR . 'assets/images/admin.ico';

            add_action( 'admin_init', array( &$this, 'at_init' ) );
            add_action( 'init', array( &$this, 'at_translate' ) );
            add_action( 'admin_menu', array( &$this, 'at_menu' ) );
            add_action( 'admin_enqueue_scripts', array( &$this, 'at_assets' ) );
            add_action( 'login_head', array( &$this, 'at_login_css' ) );
            add_action( 'login_footer', array( &$this, 'at_login_footer' ) );
            add_action( 'login_head', array( &$this, 'at_admin_favicon' ));
            add_action( 'admin_head', array( &$this, 'at_admin_favicon' ));
            add_action( 'wp_dashboard_setup',  array( &$this, 'at_add_dashboard_widgets' ));
            add_action( 'wp_dashboard_setup',  array( &$this, 'at_remove_dashboard_widgets')  );
            add_action( 'wp_dashboard_setup',  array( &$this, 'at_remove_activity_dashboard_widget')  );

            add_filter( 'login_headertitle', array( &$this, 'at_login_title' ) );
            add_filter( 'login_headerurl', array( &$this, 'at_login_url' ) );
            add_filter( 'admin_footer_text', array( &$this, 'at_admin_footer' ) );
            //remove wellcome to wordpress
            remove_action( 'welcome_panel', 'wp_welcome_panel' );

            // הוספת הוקים לבדיקת עדכונים
            add_filter('pre_set_site_transient_update_plugins', array($this, 'check_for_plugin_update'));
            add_filter('plugins_api', array($this, 'plugin_api_call'), 10, 3);
        }

        /* ... המשך הקוד מהמקור ... */

        /**
         * בדיקת עדכונים זמינים לפלאגין
         */
        public function check_for_plugin_update($transient) {
            if (empty($transient->checked)) {
                return $transient;
            }

            // קבלת המידע על העדכון מקובץ ה-JSON
            $remote_info = wp_remote_get('https://raw.githubusercontent.com/amit-trabelsi-digital/at-branding-wp-plugin/main/plugin-info.json');

            if (!is_wp_error($remote_info) && isset($remote_info['response']['code']) && $remote_info['response']['code'] == 200) {
                $remote_info = json_decode(wp_remote_retrieve_body($remote_info), true);
                
                $plugin_slug = plugin_basename(__FILE__);
                $plugin_info = $remote_info['at-branding/at-branding.php'];
                
                if (version_compare($this->get_plugin_version(), $plugin_info['version'], '<')) {
                    $transient->response[$plugin_slug] = (object) array(
                        'slug' => 'at-branding',
                        'new_version' => $plugin_info['version'],
                        'package' => $plugin_info['package'],
                        'tested' => get_bloginfo('version'),
                        'requires' => '5.0',
                        'url' => 'http://atd.digital'
                    );
                }
            }

            return $transient;
        }

        /* ... שאר הפונקציות ... */
    }
}

/* שאר הקוד מהמקור */
require_once 'at-functions.php'; 