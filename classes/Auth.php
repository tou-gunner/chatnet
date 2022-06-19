<?php

/* user authentication class */

class Auth
{
    function __construct() {
        if (isset($_COOKIE['cn_auth_key']) && !isset($_SESSION['user'])) {
            // try {
            //     app('db')->where('auth_key', $_COOKIE['cn_auth_key']);
            //     $user = app('db')->getOne('users');
            //     if ($user) {
            //         $passwprd_verify = password_verify($user['password'], $_COOKIE['cn_auth_key']);
            //         if ($passwprd_verify) {
            //             $this->updateLastLogin($user['id']);
                        
            //             $_SESSION['user'] = $this->user($user['id']);
            //             if(DISABLE_MULTIPLE_SESSIONS){
            //                 $auth_key = password_hash($user['password'], PASSWORD_DEFAULT);
            //                 $data = array();
            //                 $data['auth_key'] = $auth_key;
            //                 app('db')->where('id', $user['id']);
            //                 app('db')->update('users', $data);
            //                 cn_setcookie('cn_auth_key', $auth_key, time() + (86400 * 30), "/");
            //             }
            //         }
            //     }
            // }catch(Exception $e){
            //     //pass
            // }

            try {
                $user = $this->verify_token($_COOKIE['cn_auth_key']);
                if ($user) {
                    app('db')->where('id', $user['member_id']);
                    $user_data = app('db')->getOne('user_extend');
                    $user = array_merge($user, $user_data);
                    $user['avatar_url'] = getUserAvatarURL($user);
                    $this->updateLastLogin($user['member_id']);
                    $_SESSION['user'] = $user;
                    if(DISABLE_MULTIPLE_SESSIONS){
                        $auth_key = $_COOKIE['cn_auth_key'];
                        cn_setcookie('cn_auth_key', $auth_key, time() + (86400 * 30), "/");
                    }
                }
            } catch (\Throwable $th) {
                //throw $th;
            }
        }
    }

    private function verify_token($token) {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL,"https://alomall.la/demo/api/mobile/index.php?w=authentication&t=verify_token");
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_POSTFIELDS, 
            http_build_query(array('accessToken' => "$token")));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $server_output = json_decode(curl_exec($ch), true);
        curl_close ($ch);
        if ($server_output) {
            if ($server_output['code'] == 200) {
                $user = $server_output['datas'];
                return $user;
            } else {
                return null;
            }
        }
    }

    public function get_member($id) {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL,"https://alomall.la/demo/api/mobile/index.php?w=authentication&t=get_member");
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_POSTFIELDS, 
            http_build_query(array('id' => "$id")));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $server_output = json_decode(curl_exec($ch), true);
        curl_close ($ch);
        if ($server_output) {
            if ($server_output['code'] == 200) {
                $user = $server_output['datas'];
                return $user;
            } else {

            }
        }
    }

    // Check whether user is logged in
    public function isAuthenticated()
    {
        if (isset($_SESSION['user'])) {
            return true;
        } else {
            return false;
        }
    }

    public function get_otp($phone) {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL,"https://alomall.la/demo/api/mobile/index.php?w=authentication&t=get_otp");
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_POSTFIELDS, 
                 http_build_query(array('phoneNumber' => "$phone")));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $output = curl_exec($ch);
        curl_close ($ch);
        if ($output == "OK") {
            if ($output['code'] == 200) {
                return true;
            } else {
                app('msg')->error(__('Phone is invalid!'));
            }
        }
    }

    public function phone_authenticate($phone, $otp)
    {
        $ch_verifyOtp = curl_init();
        curl_setopt($ch_verifyOtp, CURLOPT_URL,"https://alomall.la/demo/api/mobile/index.php?w=authentication&t=verify_otp");
        curl_setopt($ch_verifyOtp, CURLOPT_POST, 1);
        curl_setopt($ch_verifyOtp, CURLOPT_POSTFIELDS, 
                 http_build_query(array(
                    'phoneNumber' => "$phone", 
                    'otp' => "$otp"
                ))
            );
        curl_setopt($ch_verifyOtp, CURLOPT_RETURNTRANSFER, true);
        $otpOutput = json_decode(curl_exec($ch_verifyOtp), true);
        curl_close($ch_verifyOtp);
        if ($otpOutput && $otpOutput['code'] == 200) {
            $token = $otpOutput['datas']['token'];
            $ch_verifyToken = curl_init();
            curl_setopt($ch_verifyToken, CURLOPT_URL,"https://alomall.la/demo/api/mobile/index.php?w=authentication&t=verify_token");
            curl_setopt($ch_verifyToken, CURLOPT_POST, 1);
            curl_setopt($ch_verifyToken, CURLOPT_POSTFIELDS, 
                     http_build_query(array(
                        'accessToken' => "$token"
                    ))
                );
            curl_setopt($ch_verifyToken, CURLOPT_RETURNTRANSFER, true);
            $member_output = json_decode(curl_exec($ch_verifyToken), true);
            curl_close($ch_verifyToken);
            if ($member_output['code'] == 200) {
                $user = $member_output['datas'];
    
                app('db')->where('id', $user['member_id']);
                $user_data = app('db')->getOne('user_extend');
                if ($user_data == null) {
                    $user_data = array();
                    $user_data['id'] = $user['member_id'];
                    $user_data['user_type'] = 1;
                    $user_data['user_status'] = 1;
                    $user_data['available_status'] = 1;
                    app('db')->insert('user_extend', $user_data);
                }
                $user = array_merge($user, $user_data);
                
                $_SESSION['user'] = $user;
                cn_setcookie('cn_auth_key', $token, time() + (86400 * 30), "/");
                return $user;
            }
            return null;
        }
        return null;
        // Further processing ...
        // if ($server_output == "OK") {
        //     if ($server_output['code'] == 200) {
        //         return true;
        //     } else {
        //         app('msg')->error(__('Phone is invalid!'));
        //     }
        // }
    }

    // Log in user by email and password
    public function authenticate($email, $password, $hybridauth=false)
    {   
        if (filter_var($email, FILTER_VALIDATE_EMAIL)) {
            app('db')->where('email', $email);
            $valid_email = true;
            $valid_username = false;
        }else{
            app('db')->where('user_name', $email);
            $valid_username = true;
            $valid_email = false;
        }
        if ($valid_email || $valid_username ) {
            if ($user = app('db')->getOne('users')) {
                if($user['available_status'] == 1){
                    if ($hybridauth) {
                        $passwprd_verify = true;
                    }else{
                        $passwprd_verify = password_verify($password, $user['password']);
                    }
                    if ($passwprd_verify) {
                        
                        $this->updateLastLogin($user['id']);
                        $_SESSION['user'] = $this->user($user['id']);
                        if(DISABLE_MULTIPLE_SESSIONS && $user['auth_key'] == ''){
                            $auth_key = password_hash($user['password'], PASSWORD_DEFAULT);
                            $data = array();
                            $data['auth_key'] = $auth_key;
                            app('db')->where('id', $user['id']);
                            app('db')->update('users', $data);
                            cn_setcookie('cn_auth_key', $auth_key, time() + (86400 * 30), "/");
                        }else{
                            if ($user['auth_key'] == '') {
                                $auth_key = password_hash($user['password'], PASSWORD_DEFAULT);
                                $data = array();
                                $data['auth_key'] = $auth_key;
                                app('db')->where('id', $user['id']);
                                app('db')->update('users', $data);
                                cn_setcookie('cn_auth_key', $auth_key, time() + (86400 * 30), "/");
                            }else{
                                cn_setcookie('cn_auth_key', $user['auth_key'], time() + (86400 * 30), "/");
                            }

                        }
                        return true;
                    } else {
                        // Wrong Password
                        app('msg')->error(__('Wrong Password!'));
                        return false;
                    }
                }else if($user['available_status'] == 3){
                    // Pending account
                    app('msg')->error(__('Your account is pending activation!'));
                    app('msg')->info('<a href="'.route('resend-activation').'">'.__('Resend Activation Email').'</a>');
                    return false;
                }else{
                    // Inactive account
                    app('msg')->error(__('Your account is disabled!'));
                    return false;
                }
            } else {
                // Wrong Email
                app('msg')->error(__('Wrong Email or Username!'));
                return false;
            }
        }else{
            app('msg')->error(__('Email or Username is invalid!'));
            return false;
        }
    }

    // Log in guest user by username
    public function guest_authenticate($guest_name, $guest_username, $sex, $dob, $country, $timezone){
        $valid = true;
        $message = '<ul>';
        $validate_data = clean_and_validate('user_name', $guest_name);
        $value = $validate_data[0];

        if(!$validate_data[1][0]){
            $valid = false;
            foreach ($validate_data[1][1]['first_name'] as $each_error) {
                $message .= "<li>".$each_error."</li>";
            }
        }

        app('db')->where('user_name', $guest_username);
        $user_name_exist = app('db')->getOne('users');
        if ($user_name_exist) {
            $valid = false;
            $message .= "<li>".__('Guest Name Already Taken')."</li>";
        }


        $message .= "</ul>";

        if($valid){
            $data['first_name'] = $guest_name;
            $data['last_name'] = "";
            $data['email'] = "";
            $data['password'] = "";
            $data['user_name'] = $guest_username;
            $data['user_type'] = 3;
            $data['user_status'] = 1;
            $data['available_status'] = 1;
            $data['created_at'] = app('db')->now();

            if ($sex) {
                $data['sex'] = $sex;
            }

            if ($dob) {
                $data['dob'] = $dob;
            }

            if ($country) {
                $data['country'] = $country;
            }

            if ($timezone) {
                $data['timezone'] = $timezone;
            }

            $id = app('db')->insert ('users', $data);
            if($id){
                $this->updateLastLogin($id);
                $_SESSION['user'] = $user = $this->user($id);

                if(DISABLE_MULTIPLE_SESSIONS && $user['auth_key'] == ''){
                    $auth_key = password_hash($user['password'], PASSWORD_DEFAULT);
                    $data = array();
                    $data['auth_key'] = $auth_key;
                    app('db')->where('id', $user['id']);
                    app('db')->update('users', $data);
                    cn_setcookie('cn_auth_key', $auth_key, time() + (86400 * 30), "/");
                }else{
                    if ($user['auth_key'] == '') {
                        $auth_key = password_hash($user['password'], PASSWORD_DEFAULT);
                        $data = array();
                        $data['auth_key'] = $auth_key;
                        app('db')->where('id', $user['id']);
                        app('db')->update('users', $data);
                        cn_setcookie('cn_auth_key', $auth_key, time() + (86400 * 30), "/");
                    }else{
                        cn_setcookie('cn_auth_key', $user['auth_key'], time() + (86400 * 30), "/");
                    }

                }

                return true;
            }else {
                app('msg')->error('Something went wrong!');
                return false;
            }
        }else {
            app('msg')->error($message);
            return false;
        }
    }

    // Add new user to the system
    public function registerNewUser($user_name, $first_name, $last_name, $user_email, $password, $password_repeat, $sex, $dob, $country, $timezone)
    {
        // check provided data validity
        if (empty($user_name)) {
            app('msg')->error(__('Username is required!'));
            return false;
        } elseif (preg_match('/[^a-z_\-0-9.]/i', $user_name)) {
            app('msg')->error(__('Username is invalid!'));
            return false;
        } elseif (empty($user_email)) {
            app('msg')->error(__('Email is required!'));
            return false;
        } elseif (!filter_var($user_email, FILTER_VALIDATE_EMAIL)) {
            app('msg')->error(__('Email is invalid!'));
            return false;
        } elseif (empty($password) || empty($password_repeat)) {
            app('msg')->error(__('Password is required!'));
            return false;
        } elseif ($password !== $password_repeat) {
            app('msg')->error(__('Password mismatch!'));
            return false;
        } else {
            app('db')->where('email', $user_email);
            $user_email_exist = app('db')->getOne('users');

            app('db')->where('user_name', $user_name);
            $user_name_exist = app('db')->getOne('users');

            if ($user_email_exist) {
                app('msg')->error(__('Email already exists!'));
                return false;
            } elseif ($user_name_exist) {
                app('msg')->error(__('Username is already taken!'));
                return false;
            } else {
                $data = array("user_name" => $user_name,
                               "first_name" => $first_name,
                               "last_name" => $last_name,
                               "email" => $user_email,
                               "password" => $password,
                            );
                if ($sex) {
                    $data["sex"] = $sex;
                }
                if ($dob) {
                    $data["dob"] = $dob;
                }
                if ($country) {
                    $data["country"] = $country;
                }
                if ($timezone) {
                    $data["timezone"] = $timezone;
                }
                $valid = true;
                $message = '<ul>';
                foreach ($data as $key => $value) {
                    $validate_data = clean_and_validate($key, $value);
                    $value = $validate_data[0];
                    $data[$key] = $value;
                    if(!$validate_data[1][0]){
                        $valid = false;
                        foreach ($validate_data[1][1][$key] as $each_error) {
                            $message .= "<li>".$each_error."</li>";
                        }
                    }
                }
                $message .= "</ul>";
                if($valid){
                    $data['password'] = password_hash(trim($password), PASSWORD_DEFAULT);
                    $data['user_status'] = 1;
                    $data['available_status'] = 1;
                    $data['created_at'] = app('db')->now();
                    $id = app('db')->insert ('users', $data);
                    if($id){
                        return $id;
                    }else {
                        app('msg')->error(__('Something went wrong!'));
                        return false;
                    }
                }else {
                    app('msg')->error($message);
                    return false;
                }
            }
        }
    }

    // public function get_user_by_id($id){
    //     if ($id) {

    //         app('db')->where('id', $id);
    //         $user_data = app('db')->getOne('users');

    //         $user_data['avatar_url'] = getUserAvatarURL($user_data);

    //         $user_data['user_status_class'] = "";
    //         if ($user_data['user_status'] == 1) {
    //             $user_data['user_status_class'] = "online";
    //         } elseif ($user_data['user_status'] == 2) {
    //             $user_data['user_status_class'] = "offline";
    //         } elseif ($user_data['user_status'] == 3) {
    //             $user_data['user_status_class'] = "busy";
    //         } elseif ($user_data['user_status'] == 4) {
    //             $user_data['user_status_class'] = "away";
    //         }
    //         return $user_data;

    //     }
    // }

    // Get user data
    // public function user($id = false)
    // {
    //     if ($id) {
    //         return $this->get_user_by_id($id);
    //     } else {
    //         if (isset($_SESSION['user'])) {
    //             if(isset($_GET['view-as']) && $_SESSION['user']['user_type'] == 1){
    //                 return $_SESSION['view-as'];
    //             }else{
    //                 return $_SESSION['user'];
    //             }
    //         } else {
    //             $nouser = array(
    //                 'id' => 0,
    //                 'timezone' => SETTINGS['timezone'],
    //                 'user_type' => 0,
    //             );
    //             return $nouser;
    //         }

    //     }
    // }

    public function get_user_by_id($id){
        if ($id) {
            $user = $this->get_member($id);

            app('db')->where('id', $id);
            $user_data = app('db')->getOne('user_extend');

            $user = array_merge($user, $user_data);
            $user['avatar_url'] = getUserAvatarURL($user);
            $user['user_status_class'] = "";
            if ($user['user_status'] == 1) {
                $user['user_status_class'] = "online";
            } elseif ($user['user_status'] == 2) {
                $user['user_status_class'] = "offline";
            } elseif ($user['user_status'] == 3) {
                $user['user_status_class'] = "busy";
            } elseif ($user['user_status'] == 4) {
                $user['user_status_class'] = "away";
            }
            return $user;

        }
    }

    public function user($id = false)
    {
        if ($id) {
            return $this->get_user_by_id($id);
        } else {
            if (isset($_SESSION['user'])) {
                if(isset($_GET['view-as']) && $_SESSION['user']['user_type'] == 1){
                    return $_SESSION['view-as'];
                }else{
                    return $_SESSION['user'];
                }
            } else {
                $nouser = array(
                    'id' => 0,
                    'timezone' => SETTINGS['timezone'],
                    'user_type' => 0,
                );
                return $nouser;
            }

        }
    }

    // Save user profile with provided data
    public function saveProfile($data, $admin_update)
    {
        app('db')->where('id', $data['id']);
        if (app('db')->update('users', $data)) {
            if(!$admin_update){
                $_SESSION['user'] = $this->user($data['id']);
            }
            return [true, __('Successfully saved!')];
        } else {
            app('msg')->error(__('Something went wrong!'));
            return [false, __('Something went wrong!')];
        }

    }

    // add new user profile with provided data
    public function addProfile($data)
    {
        if (app('db')->insert('users', $data)) {
            return [true, __('Successfully saved!')];
        } else {
            app('msg')->error(__('Something went wrong!'));
            return [false, __('Something went wrong!')];
        }

    }

    // Send password reset link with a reset key
    function sendResetPasswordLink($email){
        if (filter_var($email, FILTER_VALIDATE_EMAIL)) {
            app('db')->where('email', $email);
            $user_email_exist = app('db')->getOne('users');
            if ($user_email_exist) {
                $reset_key = uniqid('cn_',true);
                $data = array();
                $data['reset_key'] = $reset_key;
                app('db')->where('email', $email);
                app('db')->update('users', $data);
                $email_data['reset_link'] = route('reset-password').'?reset_key='.$reset_key;
                $body = app('twig')->render('emails/password_reset.html', $email_data);
                send_mail($email, SETTINGS['site_name'].' Password Reset', $body);
                app('auth')->logIP($email,3,'Success');
            }else{
                app('auth')->logIP($email,3,'Failed');
            }
            app('msg')->success(__('If the provided email is on our database, We have sent a password reset link.'));
            return [true, __('Email sent!')];
        }else{
            app('msg')->error(__('Email is invalid!'));
            return [false, ''];
        }
    }

    // Reset password if the reset key is valid
    function resetPassword($reset_key, $password){
        app('db')->where('reset_key', $reset_key);
        $user_exist = app('db')->getOne('users');
        if (empty($password)) {
            return [false, __('Empty Password')];
        } elseif (empty($reset_key)) {
            return [false, __('Empty Reset Key')];
        }elseif (!$user_exist) {
            return [false, __('Wrong Reset Key')];
        }else{
            $data = array();
            $data['password'] = password_hash($password, PASSWORD_DEFAULT);
            $data['reset_key'] = '';
            $data['auth_key'] = null;
            app('db')->where('reset_key', $reset_key);
            app('db')->update('users', $data);
            return [true, __('Password Reseted Successfully')];
        }
    }

    function nextGuestUser(){
        app('db')->orderBy('id', 'desc');
        $next_id = app('db')->getOne('users')['id']+1001;
        $next_username = 'guest_'.$next_id;
        if($this->checkUserName($next_username)){
            $go_forward = true;
        }else{
            $go_forward = false;
            do {
                $next_id += 100 ;
                $next_username = 'guest_'.$next_id;
                $go_forward = $this->checkUserName($next_username);
                if($go_forward){
                    break;
                }
            } while (!$go_forward);
        }

        $next_guest_data =  array();
        if($go_forward){
            $next_guest_data['guest_username'] = $next_username;
            $next_guest_data['guest_userid'] = $next_id;
        }
        return $next_guest_data;
    }

    function checkUserName($user_name){
        app('db')->where('user_name', $user_name);
        if(app('db')->getOne('users')){
            return false;
        }else{
            return true;
        }
    }

    function updatePushDevices($post_data, $user_id){
        app('db')->where ('user_id', $user_id);
        $user_push_devices = app('db')->get('push_devices');
        if($user_push_devices){
            foreach ($user_push_devices as $each_device) {
                $push_device_data = array();
                $push_device_data['perm_group'] = 0;
                $push_device_data['perm_private'] = 0;
                $push_device_data['perm_mentions'] = 0;
                $push_device_data['perm_notice'] = 0;
                if(array_key_exists("perm_group_".$each_device['id'], $post_data)){
                    $push_device_data['perm_group'] = 1;
                }

                if(array_key_exists("perm_private_".$each_device['id'], $post_data)){
                    $push_device_data['perm_private'] = 1;
                }

                if(array_key_exists("perm_mentions_".$each_device['id'], $post_data)){
                    $push_device_data['perm_mentions'] = 1;
                }

                if(array_key_exists("perm_notice_".$each_device['id'], $post_data)){
                    $push_device_data['perm_notice'] = 1;
                }
                app('db')->where('id', $each_device['id']);
                app('db')->update('push_devices', $push_device_data);
            }
        }
    }

    function logIP($email,$type,$message){
        if (isset(SETTINGS['enable_ip_logging']) && SETTINGS['enable_ip_logging']==true) {
            $data = array();
            $data['ip'] = getClientIP();
            $geoip = getGeoIP($data['ip']);
            $data['country'] = $geoip ? $geoip['country_code'] : '';
            $data['email'] = $email;
            $data['type'] = $type;
            $data['message'] = $message;
            $data['user_agent'] = $_SERVER['HTTP_USER_AGENT'];
            $data['time'] = app('db')->now();
            app('db')->insert ('ip_logs', $data);
        }
    }



    function isIPBlocked(){
        if (isset(SETTINGS['enable_ip_blacklist']) && SETTINGS['enable_ip_blacklist']==true) {
            $ip = getClientIP();
            if ($ip) {
                $blacklist = preg_replace('/\s/', '', SETTINGS['ip_blacklist']);
                $blacklist = explode(',', $blacklist);
                if (isAllowedIp($ip, $blacklist)) {
                    return true;
                }else{
                    return false;
                }
            }else{
                return false;
            }
        }
    }


    // Send password reset link with a reset key
    function sendEmailVerificationLink($user, $activation_key){
        app('db')->where('id', $user);
        $user_data = app('db')->getOne('users');
        if ($user_data) {
            $email_data = array();
            $email_data['activation_link'] = route('activate').'?activation_key='.$activation_key;
            $body = app('twig')->render('emails/activate.html', $email_data);
            send_mail($user_data['email'], SETTINGS['site_name'].' Activate Your Account', $body);
        }
        app('msg')->success(__('Activation link has been sent! Please check your inbox.'));
        return [true, __('Email sent!')];

    }

    function updateLastLogin($user){
        $data = array();
        $data['last_login'] = app('db')->now();
        app('db')->where('id', $user);
        app('db')->update('users', $data);
    }
}
