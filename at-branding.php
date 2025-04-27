<?php
/*
Plugin Name: AT - Custom Branding
Plugin URI: http://atd.digital
Update URI: https://raw.githubusercontent.com/amit-trabelsi-digital/at-branding-updates/develop/plugin-info-dev.json
Description: An internal plugin for adding custom branding to wordpress website.
Version: 1.3.71
Author: Amit Trabelsi
Author URI: http://atd.digital
Text Domain: at
*/


if (!defined('PLUGIN_MAIN_DIR')) {
    define('PLUGIN_MAIN_DIR', plugin_dir_url(__FILE__));
}


if (!class_exists('atBranding')) {

    class atBranding
    {

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
        public function __construct()
        {

            $this->atLogo = PLUGIN_MAIN_DIR . 'assets/images/at-logo.png';
            $this->atAdminFavicon = PLUGIN_MAIN_DIR . 'assets/images/admin.ico';

            add_action('admin_init', array(&$this, 'at_init'));
            add_action('init', array(&$this, 'at_translate'));
            add_action('admin_menu', array(&$this, 'at_menu'));
            add_action('admin_enqueue_scripts', array(&$this, 'at_assets'));
            add_action('login_head', array(&$this, 'at_login_css'));
            add_action('login_footer', array(&$this, 'at_login_footer'));
            add_action('login_head', array(&$this, 'at_admin_favicon'));
            add_action('admin_head', array(&$this, 'at_admin_favicon'));
            add_action('wp_dashboard_setup', array(&$this, 'at_add_dashboard_widgets'));
            add_action('wp_dashboard_setup', array(&$this, 'at_remove_dashboard_widgets'));
            add_action('wp_dashboard_setup', array(&$this, 'at_remove_activity_dashboard_widget'));

            add_filter('login_headertitle', array(&$this, 'at_login_title'));
            add_filter('login_headerurl', array(&$this, 'at_login_url'));
            add_filter('admin_footer_text', array(&$this, 'at_admin_footer'));
            //remove wellcome to wordpress
            remove_action('welcome_panel', 'wp_welcome_panel');

            // הוספת הוקים לבדיקת עדכונים
            add_filter('pre_set_site_transient_update_plugins', array($this, 'check_for_plugin_update'));
            add_filter('plugins_api', array($this, 'plugin_api_call'), 10, 3);
        }


        /**
         * Perform the following actions on plugin activation.
         */
        public static function activate()
        {

        }


        /**
         * Perform the following actions on plugin deactivation.
         */
        public static function deactivate()
        {

        }


        /**
         * Perform the following actions on accessing the admin control panel.
         */
        public function at_init()
        {

            // Register plugin settings.
            register_setting('at-branding', 'clients_main_color');
            register_setting('at-branding', 'clients_logo_file');
            register_setting('at-branding', 'admin_favicon_file');
            register_setting('at-branding', 'at_use_sendgrid');
            register_setting('at-branding', 'at_sender_email_name');
            register_setting('at-branding', 'at_sender_email_address');
            register_setting('at-branding', 'at_sent_to_admin_default');
        }


        /**
         * Enable plugin translation.
         */
        public function at_translate()
        {

            load_plugin_textdomain('at', false, dirname(plugin_basename(__FILE__)) . '/languages/');

        }


        /**
         * Declare the plugin's settings pages and menu structure.
         */
        public function at_menu()
        {

            // Register a ne settings page and assign it to the options menu.
            add_options_page(__('AT Custom Branding', 'at'), __('Custom Branding', 'at'), 'manage_options', 'custom_branding', array(&$this, 'at_branding_page'));

        }


        /**
         * Register plugin's special assets - javascript and css files.
         */
        public function at_assets()
        {

            // Register media library upload script.
            wp_register_script('at-media-upload', PLUGIN_MAIN_DIR . '/assets/js/admin-scripts.js');
            wp_register_style('at-settings-css', PLUGIN_MAIN_DIR . '/assets/css/admin-styles.css');

            if (get_current_screen()->id == 'settings_page_custom_branding') {

                wp_enqueue_script('jquery');
                wp_enqueue_script('thickbox');
                wp_enqueue_script('media_upload');
                wp_enqueue_script('at-media-upload');

                wp_enqueue_style('thickbox');
                wp_enqueue_style('at-settings-css');

            }

        }


        /**
         * Print Branding CSS on the login page.
         */
        public function at_login_css()
        {

            $clientColor = (get_option('clients_main_color') == '') ? $this->atColor : get_option('clients_main_color');
            $clientLogo = (get_option('clients_logo_file') == '') ? $this->atLogo : get_option('clients_logo_file');

            include_once(dirname(__FILE__) . '/templates/login-css.php');

        }


        /**
         * Print a unique footer.
         */
        public function at_login_footer()
        {

            echo '<div id="at-footer" style="text-align: center; direction: ltr">';
            echo '	<a href="' . $this->atURL . '">';
            echo '		הקמה וניהול:  <img width="20px" src="' . $this->atLogo . '" alt="' . __('Amit Trabelsi Digital LTD', 'at') . '">';
            echo '	</a>';
            echo '</div>';

        }


        /**
         * Change the logo title to the website name.
         */
        public function at_login_title()
        {

            return get_bloginfo('name');

        }


        /**
         * Change the logo url to the website url.
         */
        public function at_login_url()
        {

            return get_bloginfo('url');

        }


        /**
         * Change the footer text on the admin panel.
         */
        public function at_admin_footer()
        {
            ?>
            <div style="text-align: right;direction: ltr;" class="alignleft">
                <span style="line-height: 2;"> הקמה וניהול: </span>
                <a href="<?php echo $this->atURL; ?>">
                    עמית טרבלסי דיגיטל
                </a>
            </div>
            <?php
        }


        /**
         * Build and display the plugin's settings page.
         */
        public function at_branding_page()
        {

            if (!current_user_can('manage_options')) {
                wp_die(__('You are not allowed to access this page - insufficient permissions', 'at'));
            }

            include_once(dirname(__FILE__) . '/templates/settings-page.php');

        }

        public function at_admin_favicon()
        {

            $favicon_url = (get_option('admin_favicon_file') == '') ? $this->atAdminFavicon : get_option('admin_favicon_file');
            echo '<link rel="shortcut icon" href="' . $favicon_url . '" />';
        }

        /* Add a widget to the dashboard. */
        function at_add_dashboard_widgets()
        {

            wp_add_dashboard_widget(
                'at_contact_details',
                'AT contact',
                array($this, 'at_dashboard_widget_function')
            );
        }

        /* Create the function to output the contents of our Dashboard Widget. */
        function at_dashboard_widget_function()
        {
            ?>
            <div id="contact_logo" align="center">
                <a href="https://atd.digital" target="_blank">
                    <img src="<?php echo $this->atLogo; ?>" style="width:60%">
                </a>
            </div>
            <div>
                <div class="contact"><?php _e('הרשנזון 14, רחובות', 'at'); ?></div>
                <div class="contact">שירות: <a
                        href="https://amit-trabelsi.co.il/%d7%90%d7%96%d7%95%d7%a8-%d7%9c%d7%a7%d7%95%d7%97%d7%95%d7%aa/">פתיחת
                        פנייה</a></div>
                <div class="contact">טלפון: <a href="tel:+972506362008">+972-50-6362008</a></div>
                <div class="contact">אימייל: <a href="mailto:sos@atd.digital">sos@atd.digital</a></div>
            </div>
            <?php
        }

        //clear dashbourd
        function at_remove_dashboard_widgets()
        {
            global $wp_meta_boxes;

            unset($wp_meta_boxes['dashboard']['side']['core']['dashboard_quick_press']);
            unset($wp_meta_boxes['dashboard']['normal']['core']['dashboard_incoming_links']);
            unset($wp_meta_boxes['dashboard']['normal']['core']['dashboard_right_now']);
            unset($wp_meta_boxes['dashboard']['normal']['core']['dashboard_plugins']);
            unset($wp_meta_boxes['dashboard']['normal']['core']['dashboard_recent_drafts']);
            unset($wp_meta_boxes['dashboard']['normal']['core']['dashboard_recent_comments']);
            unset($wp_meta_boxes['dashboard']['normal']['core']['dashboard_activity']);
            unset($wp_meta_boxes['dashboard']['side']['core']['dashboard_primary']);
            unset($wp_meta_boxes['dashboard']['side']['core']['dashboard_secondary']);

        }

        //remove activities from wordpress dashbourd
        function at_remove_activity_dashboard_widget()
        {
            remove_meta_box('dashboard_activity', 'dashboard', 'side');
            // remove_meta_box( 'woocommerce_dashboard_recent_reviews', 'dashboard', 'normal' );
            //remove_meta_box( 'woocommerce_dashboard_status', 'dashboard', 'normal' );
        }

        /**
         * בדיקת עדכונים זמינים לפלאגין
         */
        public function check_for_plugin_update($transient)
        {
            if (empty($transient->checked)) {
                return $transient;
            }

            // קבלת המידע על העדכון מקובץ ה-JSON מתוך ה-Update URI של הפלאגין
            // Ensure get_plugin_data is available
            if (!function_exists('get_plugin_data')) {
                require_once ABSPATH . 'wp-admin/includes/plugin.php';
            }
            $plugin_data   = get_plugin_data(__FILE__, false, false);
            $update_uri    = isset($plugin_data['UpdateURI']) ? $plugin_data['UpdateURI'] : '';
            if (empty($update_uri)) {
                return $transient;
            }

            $remote_info = wp_remote_get($update_uri);

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

        /**
         * קבלת מידע על הפלאגין עבור חלון העדכון
         */
        public function plugin_api_call($result, $action, $args)
        {
            if ($action !== 'plugin_information') {
                return $result;
            }

            if ('at-branding' !== $args->slug) {
                return $result;
            }

            // קבלת המידע על העדכון מקובץ ה-JSON מתוך ה-Update URI של הפלאגין
            // Ensure get_plugin_data is available
            if (!function_exists('get_plugin_data')) {
                require_once ABSPATH . 'wp-admin/includes/plugin.php';
            }
            $plugin_data   = get_plugin_data(__FILE__, false, false);
            $update_uri    = isset($plugin_data['UpdateURI']) ? $plugin_data['UpdateURI'] : '';
            if (empty($update_uri)) {
                return $result;
            }

            $remote_info = wp_remote_get($update_uri);

            if (!is_wp_error($remote_info) && isset($remote_info['response']['code']) && $remote_info['response']['code'] == 200) {
                $remote_info = json_decode(wp_remote_retrieve_body($remote_info), true);
                $plugin_info = $remote_info['at-branding/at-branding.php'];

                $result = (object) array(
                    'name' => $plugin_info['name'],
                    'slug' => 'at-branding',
                    'version' => $plugin_info['version'],
                    'author' => $plugin_info['author'],
                    'requires' => '5.0',
                    'tested' => get_bloginfo('version'),
                    'last_updated' => date('Y-m-d'),
                    'sections' => array(
                        'description' => 'An internal plugin for adding custom branding to wordpress website.'
                    ),
                    'download_link' => $plugin_info['package']
                );
            }

            return $result;
        }

        /**
         * קבלת הגרסה הנוכחית של הפלאגין
         */
        private function get_plugin_version()
        {
            // Ensure get_plugin_data is available
            if (!function_exists('get_plugin_data')) {
                require_once ABSPATH . 'wp-admin/includes/plugin.php';
            }
            $plugin_data = get_plugin_data(__FILE__);
            return $plugin_data['Version'];
        }

    }

}


/**
 * ===================
 * Plugin Registration
 * ===================
 */
if (class_exists('atBranding')) {

    // Register the plugin's activate & deactivation functions.
    register_activation_hook(__FILE__, array('atBranding', 'activate'));
    register_deactivation_hook(__FILE__, array('atBranding', 'deactivate'));


    // Initializing the plugin.
    $at = new atBranding();


    // Add link to the settings page on the plugins page.
    function at_add_settings_link($links)
    {

        $plugin_settings = '<a href="options-general.php?page=custom_branding">' . __('Settings', 'at') . '</a>';
        array_unshift($links, $plugin_settings);

        return $links;

    }

    $plugin_name = plugin_basename(__FILE__);

    add_filter("plugin_action_links_{$plugin_name}", 'at_add_settings_link');

}

if (!function_exists('my_plugin_check_for_updates')) {

    function my_plugin_check_for_updates($update, $plugin_data, $plugin_file)
    {

        static $response = false;

        if (empty($plugin_data['UpdateURI']) || !empty($update))
            return $update;

        if ($response === false)
            $response = file_get_contents($plugin_data['UpdateURI']);


        if (!$response)
            return $update;


        if ($plugin_data['Name'] === 'AT - Custom Branding') {
            $custom_plugins_data = json_decode(stripslashes($response), true);
        } else {
            $custom_plugins_data = json_decode($response, true);
        }

        if (!empty($custom_plugins_data[$plugin_file]))
            return $custom_plugins_data[$plugin_file];
        else
            return $update;
    }

    // פילטר מקורי עבור הדומיין הישן
    add_filter('update_plugins_amit-trabelsi.co.il', 'my_plugin_check_for_updates', 10, 3);
    // פילטר חדש עבור הדומיין של GitHub Raw בו מאוחסן קובץ ה-JSON
    add_filter('update_plugins_raw.githubusercontent.com', 'my_plugin_check_for_updates', 10, 3);
}

require_once 'at-functions.php';