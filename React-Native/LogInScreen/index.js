//LogInScreen.js
//import logo from '../../assets/fellalogo.svg';
//import SvgUri from 'react-native-svg-uri';

//Modules
import React, {Component} from 'react'
import {
    StyleSheet,
    View,
    YellowBox,
    TouchableOpacity,
    Text,
    Image,
    ImageBackground,
    ActivityIndicator
} from "react-native";
import {Input, Button} from 'react-native-elements'
import {connect} from 'react-redux'
import {bindActionCreators} from "redux";
import * as AuthActions from "../../actions/AuthActions";

import {Colors, Elements} from "../../theme";

import Icon from 'react-native-vector-icons/Feather';
import DarkGreyInput from '../../customComponents/DarkGreyInput'
import GradientedBorderBlock from '../../customComponents/GradientedBorderBlock'
import styles from './Style'
import {images} from '../../theme/Images'
import firebase from "react-native-firebase";
import LinearGradient from "react-native-linear-gradient";
import GradientButton from "../../customComponents/GradientButton";

class LoginScreen extends Component {

    constructor(props) {
        super(props);
        this.state = {
            login: '',
            pass: '',
        }
    }

    componentDidMount() {
        this.emailCheck()
    }

    componentDidUpdate(prevProps) {
        let {user} = this.props.auth
        if (user && user !== prevProps.auth.user) {
            this.emailCheck()
        }
    }

    emailCheck() {
        let {user} = this.props.auth
        if (user && !user.emailVerified && !this.props.auth.emailSent) {
            this.props.navigation.navigate('SignUpScreen')
        }
    }

    onPressLogin = () => {
        let {login, pass} = this.state
        let {authActions} = this.props
        authActions.loginRequest(login, pass)
    }

    onPressSignUp = () => {
        this.props.navigation.navigate('SignUpScreen')
    }

    onPressResetPassword = () => {
        this.props.navigation.navigate('PasswordResetScreen')
    }

    onLoginChange(val) {
        this.setState({login: val})
    }

    onPassChange(val) {
        this.setState({pass: val})
    }

    render() {
        let errors = this.props.auth.loginErrors
        let loading = this.props.auth.loginLoad
        return (
            <ImageBackground style={styles.container} source={images.loginBackground.uri}>

                <View style={styles.logoContainer}>
                    <Image source={images.logo.uri} style={styles.logoImage}/>
                </View>
                <GradientedBorderBlock style={styles.fieldsContainer} title="LOGIN">

                    {loading ?
                        <ActivityIndicator size="large" color={Colors.blue} style={styles.loader}/>
                        :
                        <View style={styles.fieldsInputsHolder}>
                            <DarkGreyInput onChangeText={(text) => this.onLoginChange(text)}
                                           placeholder='Email'
                                           value={this.state.login}
                                           errorMessage={errors.email}
                                           leftIconName='mail'
                                           keyboardType='email-address'
                            >
                            </DarkGreyInput>

                            <DarkGreyInput onChangeText={(text) => this.onPassChange(text)}
                                           placeholder='Password'
                                           value={this.state.pass}
                                           errorMessage={errors.pass}
                                           leftIconName='lock'
                                           blurOnSubmit={true}
                                           clearTextOnFocus={true}
                                           secureTextEntry={true}
                            >
                            </DarkGreyInput>
                        </View>}


                    <View style={styles.buttonsContainer}>
                        <GradientButton title='LOGIN'
                                        onPress={this.onPressLogin}/>
                        <GradientButton title='FORGOT PASSWORD'
                                        type='clear'
                                        onPress={this.onPressResetPassword}
                                        small
                        />
                    </View>



                </GradientedBorderBlock>


                <TouchableOpacity onPress={this.onPressSignUp}>
                    <View style={styles.signUpContaier}>
                        <GradientButton title='SIGN UP'
                                        type='clear'
                                        onPress={this.onPressSignUp}/>
                    </View>
                </TouchableOpacity>

            </ImageBackground>
        );
    }
}

function mapStateToProps(state, ownProps) {
    return {
        auth: state.auth
    };
}

const mapDispatchToProps = (dispatch) => {
    return {
        authActions: bindActionCreators(AuthActions, dispatch),
    }
}

export default connect(mapStateToProps, mapDispatchToProps)(LoginScreen)