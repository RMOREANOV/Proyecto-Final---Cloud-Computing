'use strict';

const { ConsoleConnector } = require('@nlpjs/basic');
/**
 * Read the documentation (https://strapi.io/documentation/v3.x/concepts/controllers.html#core-controllers)
 * to customize this controller
 */

const { parseMultipartData, sanitizeEntity } = require('strapi-utils');
const days = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
const months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];

function getDateMiliseconds(datetime){
    const hours = datetime.getUTCHours()
    const minutes = datetime.getUTCMinutes()
    return datetime.getTime()-hours*3600000-minutes*60000
}

function getDate(datetime){
    const date = datetime.getUTCDate()
    return ("0"+date).slice(-2)
}

function getMonthNames(month){
    return months[month];
}

function getDayNames(day){
    return days[day];
}

function getTimeString(datetime){
    const hours = datetime.getUTCHours()
    const minutes = datetime.getUTCMinutes()
    const AMorPM = hours<12?"AM":"PM"
    const hoursString = ("00"+(hours<=12?hours:hours-12)).slice(-2);
    const minutesString = ("00"+minutes).slice(-2);
    return hoursString+":"+minutesString+" "+AMorPM
}

function getTypeTimeString(datetime){
    const hours = datetime.getUTCHours()
    var typeTime = "evening"
    if(hours<12){
        typeTime = "morning"
    }else if(hours<18){
        typeTime = "afternoon"
    }
    return typeTime
}

module.exports = {
    async find(ctx) {
        let entities;
        if (ctx.query._q) {
          entities = await strapi.services['medical-consultation'].search(ctx.query, ['doctor', 'doctor.photo', 'doctor.specialty', 'patient', 'patient.photo']);
        } else {
          entities = await strapi.services['medical-consultation'].find(ctx.query, ['doctor', 'doctor.photo', 'doctor.specialty', 'patient', 'patient.photo']);
        }
        return entities.map(entity => sanitizeEntity(entity, { model: strapi.models['medical-consultation'] }));
      },
    async allDataMedicalConsultation(ctx) {
        const genders = await strapi.services.gender.find({});
        const specialties = await strapi.services.specialty.find({_sort: 'name:asc'}, ['doctors','doctors.photo']);
        const medicalConsultations = await strapi.services['medical-consultation'].find({isVisible: true, _sort: 'datetime:asc'});
        var doctorsIdInmedicalConsultations = []
        for(var i=0;i<medicalConsultations.length;i++){
            if(medicalConsultations[i]['patient']!=null){
                medicalConsultations.splice(i,1);
                i--;
            }else{
                if(!doctorsIdInmedicalConsultations.includes(medicalConsultations[i]['doctor']['id'])){
                    doctorsIdInmedicalConsultations.push(medicalConsultations[i]['doctor']['id']);
                }
            }
        }
        for(var i=0;i<specialties.length;i++){
            for(var j=0;j<specialties[i]['doctors'].length;j++){
                if(!doctorsIdInmedicalConsultations.includes(specialties[i]['doctors'][j]['id'])){
                    specialties[i]['doctors'].splice(j,1);
                    j--;
                }
            }
            if(specialties[i]['doctors'].length==0){
                specialties.splice(i,1);
                i--;
            }
        }

        for(var i=0;i<medicalConsultations.length;i++){
            var medicalConsultationsDatetimeUTC = new Date(medicalConsultations[i]['datetime']).getTime()

            //var medicalConsultationsDatetimeOffset = new Date(medicalConsultations[i]['datetime']).getTimezoneOffset() * 60000;
            var medicalConsultationsDatetimeOffset = parseInt(ctx.query.timezoneOffsetMilliseconds);
            var medicalConsultationsDatetimeLocale = medicalConsultationsDatetimeUTC + medicalConsultationsDatetimeOffset;
            var medicalConsultationsDatetimeLocaleDatetime = new Date(medicalConsultationsDatetimeLocale)
            medicalConsultations[i]['localeDateMiliseconds'] = getDateMiliseconds(medicalConsultationsDatetimeLocaleDatetime);
            medicalConsultations[i]['localeDate'] = getDate(medicalConsultationsDatetimeLocaleDatetime);         
            medicalConsultations[i]['localeFullYear'] = medicalConsultationsDatetimeLocaleDatetime.getUTCFullYear();
            medicalConsultations[i]['localeMonthNames'] = getMonthNames(medicalConsultationsDatetimeLocaleDatetime.getUTCMonth());
            medicalConsultations[i]['localeDayNames'] = getDayNames(medicalConsultationsDatetimeLocaleDatetime.getUTCDay());
            medicalConsultations[i]['localeTimeString'] = getTimeString(medicalConsultationsDatetimeLocaleDatetime);
            medicalConsultations[i]['localeTypeTime'] = getTypeTimeString(medicalConsultationsDatetimeLocaleDatetime);
        }
        return {genders: genders, specialties: specialties, medicalConsultations: medicalConsultations}
    },
};
