import * as types from '../constants/AuthActionTypes'
import * as HomesActions from './HomesActions'
import DarkAlertActions from './DarkAlertActions'
import {ToastActionsCreators} from 'react-native-redux-toast'
import RNReactLogging from 'react-native-file-log'

import firebase from 'react-native-firebase';
import RoomConstants from "../constants/RoomConstants";

//Storage
import * as StorageActions from '../helpers/Storage'
import {SearchDeviceConstants, WeatherConstants} from '../constants/StorageConstants'

const firebaseUserCollection = firebase.firestore().collection('user')

const defaultHome = {
    name: 'My Home',
    zip: '',
}
const defaultRoom = {
    name: RoomConstants.ALL_DEVICES,
    devices: [],
    rooms: [],
}


function loginRequest(login, password) {
    return (dispatch) => {
        dispatch(loginLoad())
        firebase.auth().signInWithEmailAndPassword(login, password).catch((error) => {
            dispatch(loginError(error))
        }).then((user => {
            dispatch(loginSuccess(user.user))
        }))
    }
}

function signUpRequest(userdata) {
    return (dispatch) => {
        dispatch(signUpLoad())
        firebase.auth().createUserWithEmailAndPassword(userdata.email, userdata.password).catch((error) => {
            dispatch(signUpError(error))
        }).then((user) => {
            let {firstName, lastName, email, phone} = userdata
            let deliver = firebase.auth().currentUser


            //create user default data
            deliver.updateProfile({displayName: `${firstName} ${lastName}`}).then(() => {
                let firebaseUser = firebaseUserCollection.doc(deliver._user.uid)
                firebaseUser.set({firstName, lastName, email, phone}).then(() => {
                    firebaseUser.collection('homes').add(defaultHome).then((home) => {
                        firebaseUser.collection('homes').doc(home.id).collection('rooms').add(defaultRoom).then(() => {
                            dispatch(signUpSuccess(deliver))
                            deliver.sendEmailVerification()
                        })

                    })
                })
            })

        })
    }
}

function getUserData(user) {
    return dispatch =>
        firebaseUserCollection.doc(user.uid).get().catch(error => {
            RNReactLogging.printLog(error);
        }).then(userbase => {
            if (userbase.data()) {
                dispatch(userDataSet(userbase.data()))
            } else {
                let userData = {
                    firstName: "",
                    lastName: "",
                    email: user.email,
                    phone: '',
                }
                firebaseUserDataCreate(user.uid, userData)
                dispatch(userDataSet(userData))
            }
        })
}

function logout() {
    return (dispatch) => {
        firebase.auth().signOut().then(() => {
                dispatch(logoutSuccess())
            }
        )
    }
}

function updateGeneralInfo(uid, info) {
    return dispatch => {
        let {firstName, lastName, email} = info
        firebaseUserCollection.doc(uid).update({firstName, lastName, email}).then(() => {
            dispatch(userDataSet(info))
            dispatch(ToastActionsCreators.displayInfo('User info updated'))
        })
    }
}

function updatePassword(uid, password) {
    return dispatch => {

        let user = firebase.auth().currentUser

        user.updatePassword(password).then(() => {
            dispatch(ToastActionsCreators.displayInfo('Password updated'))
        }).catch((error) => {
            RNReactLogging.printLog('updatePassword error: ' + error);
        });
    }
}

function sendEmailVerification() {
    let user = firebase.auth().currentUser
    user.sendEmailVerification()
    return {
        type: types.MAIL_SENT
    }
}

function loginLoad() {
    return {
        type: types.LOGIN_REQUEST
    }
}

function loginError(error) {
    return {
        type: types.LOGIN_ERROR,
        error: error
    }
}

function loginSuccess(user) {
    return {
        type: types.LOGIN_SUCCESS,
        user: user
    }
}

function signUpLoad() {
    return {
        type: types.SIGN_IN_REQUEST,
    }
}

function signUpSuccess(user) {
    return {
        type: types.SIGN_IN_SUCCESS,
        user: user
    }
}

function signUpError(error) {
    return {
        type: types.SIGN_IN_ERROR,
        error: error
    }
}

function userDataSet(data) {
    return {
        type: types.USER_DATA_GET_SUCCESS,
        data
    }
}

function setWeatherWidgetAction(val) {
    return dispatch => {
        let value = val == true ? 1 : 0
        StorageActions.storeData(WeatherConstants.WeatherWidget, value).then(() => {
            dispatch(setWeatherWidget(value))
        })

    }
}
function setWeatherWidget(val) {
    return {
        type: types.SET_WEATHER_WIDGET,
        widgetState: val
    }
}

function logoutSuccess() {
    return {
        type: types.LOGOUT
    }
}

function changeSimulatedDevices(val) {
    return {
        type: types.SIMULATED_DEVICES_TOGGLE,
        val: val,
    }
}

function actionsChangeSimulatedDevices(val) {
    return (dispatch) => {

        if (val != undefined) {
            let storedValue = val == true ? 1 : 0
            StorageActions.storeData(SearchDeviceConstants.SimulatedDevices, storedValue)
            dispatch(changeSimulatedDevices(val))
        }
    }
}

function actionsLoadSimulatedDeviceValue() {
    return (dispatch) => {

        StorageActions.getData(SearchDeviceConstants.SimulatedDevices).then((responce) => {
            if (responce != undefined) {
                let storedValue = responce == 1 ? true : false
                dispatch(changeSimulatedDevices(storedValue))
            } else {
                dispatch(changeSimulatedDevices(false))
            }
        }).catch((error) => {
            dispatch(changeSimulatedDevices(false))
        });
    }
}


module.exports = {
    loginRequest,
    loginSuccess,
    loginError,
    signUpRequest,
    signUpSuccess,
    signUpError,
    getUserData,
    logout,
    logoutSuccess,
    sendEmailVerification,
    changeSimulatedDevices,
    actionsChangeSimulatedDevices,
    actionsLoadSimulatedDeviceValue,
    updateGeneralInfo,
    updatePassword,
    setWeatherWidgetAction,
    setWeatherWidget
}