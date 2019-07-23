//LoginReducer.js

//Constants
import * as types from '../constants/AuthActionTypes'
import * as storage from '../helpers/Storage'

const initialState = {
    loginLoad: false,
    signInLoad: false,
    uid: null,
    user: null,
    userData: null,
    loginErrors: {
        email: null,
        pass: null,
    },
    signInErrors: {
        email: null,
        pass: null,
    },
    emailSent: false,
    simulatedDevices: false,
    weatherWidget: false,
}

export default function (state = initialState, action) {
    switch (action.type) {
        case types.LOGIN_REQUEST:
            return {...state, loginLoad: true, loginErrors: {email: null, pass: null,}, user: null}

        case types.LOGIN_SUCCESS:
            let user = action.user._user
            return {...state, loginLoad: false, user: user, uid: user.uid, loginErrors: {email: null, pass: null,}}

        case types.LOGIN_ERROR: {
            let errors = state.loginErrors
            switch (action.error.code) {
                case 'auth/invalid-email': {
                    errors.email = 'This email is invalid'
                    break;
                }
                case 'auth/user-disabled': {
                    errors.email = 'There is no user corresponding to the given email'
                    break;
                }
                case 'auth/user-not-found': {
                    errors.email = 'User not found'
                    break;
                }
                case 'auth/wrong-password': {
                    errors.pass = 'Password is invalid for the given email'
                    break;

                }
            }
            return {...state, loginLoad: false, loginErrors: errors}
        }
        case types.USER_DATA_GET_SUCCESS: {
            return {...state, userData: action.data}
        }
        case types.SIGN_IN_REQUEST:
            return {...state, signInLoad: true, signInErrors: null}
        case types.SIGN_IN_SUCCESS:
            return {...state, signInLoad: false, user: action.user}
        case types.SIGN_IN_ERROR: {
            let errors = {
                email: null,
                pass: null,
            }
            switch (action.error.code) {
                case 'auth/email-already-in-use': {
                    errors.email = 'This email is already in use.'
                    break;
                }
                case 'auth/invalid-email': {
                    errors.email = 'This email is invalid.'
                    break;
                }
                case 'auth/operation-not-allowed': {
                    errors.email = 'User not found.'
                    break;
                }
                case 'auth/weak-password': {
                    errors.pass = 'Password is not strong enough.'
                    break;
                }
            }
            return {...state, signInLoad: false, signInErrors: errors}
        }
        case types.SET_WEATHER_WIDGET: {
            storage.storeData('weatherWidget', action.widgetState)
            return {...state, weatherWidget: action.widgetState}
        }
        case types.LOGOUT:
            return {...initialState}
        case types.MAIL_SENT:
            return {...state, emailSent: true}
        case types.SIMULATED_DEVICES_TOGGLE:
            return {...state, simulatedDevices: action.val}
        default:
            return state;
    }
}
