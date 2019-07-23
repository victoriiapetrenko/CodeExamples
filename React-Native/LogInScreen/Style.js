import { Dimensions } from 'react-native'
import { ScaledSheet } from 'react-native-size-matters'
import { getStatusBarHeight } from 'react-native-status-bar-height'

import {Colors, Fonts, ApplicationStyles} from "../../theme";

const { width,height } = Dimensions.get('window')
const statusBarHeight = getStatusBarHeight()

export default ScaledSheet.create({
    container: {
        flex: 1,
        flexDirection: "column",
        justifyContent:'flex-start',
        backgroundColor: Colors.transparent,
        paddingTop: statusBarHeight+90,
        paddingHorizontal: 30,
    },
    logoContainer:{
        width: 140,
        height:108,
        alignSelf:'center',
        marginLeft: -30,
        shadowColor:'#000',
        shadowOpacity: 0.4,
        shadowOffset: {width: 10, height: 10},
        shadowRadius: 10,
        zIndex: 2,
        marginBottom: -30
    },
    logoImage:{
        width: '100%',
        height: '100%',

    },
    fieldsContainer: {
        zIndex: 1,
        alignItems: 'stretch',

    },
    fieldsInputsHolder:{
       paddingHorizontal: 20,
    },
    loader:{
        paddingVertical: 39.9,
    },
    signUpContaier:{
        //borderWidth: 6,
        //borderColor: Colors.orange,
        width: 170,
        height: 50,
        alignSelf: 'center',
        marginBottom: 50,
        justifyContent: 'center',
    },
    signUpText:{
        color: Colors.blue,
        fontWeight: '600',
        fontSize: 18,
        textAlign: 'center',
    },
    buttonsContainer:{
        marginTop:15,
        alignItems: 'stretch',
        width: '100%',
    },

})