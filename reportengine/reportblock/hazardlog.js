/* reposyd-reportblock-header */
/* eslint-disable no-useless-constructor */
const LexicographicalOrder = require( 'lexicographicalorder' )
const ReportBlock = require( 'ReportBlock' )
const ReportTable = require( 'ReportTable' )
const Rule = require( 'js-rules-engine' ).Rule
/* reposyd-reportblock-header */

class ReportBlockHazardLog extends ReportBlock {
  constructor( section, engine ) {
    super( section, engine )
    /* reposyd-reportblock-constructor */
    /* reposyd-reportblock-constructor */
  }

  /* reposyd-reportblock-body */
  renderContent() {
    this.renderSeverityDefinition()
    this.renderFrequencyDefinition()
    this.renderProbabilityDefinition()
    this.renderAvoidanceDefinition()
    this.renderRisikoMatrixDefinition()
    this.insertPageBreak()
  
    this.hazardLog().forEach((item, index) => {
      if (index > 0) {
        this.insertPageBreak()
      }
      this.renderHazard(item.hazard, index)
      this.writeHtml('Gefährdungsrisiko', 'title')
      this.renderAssessment(item.assessment)
      this.writeHtml('Maßnahmen zur Gefahrenminderung', 'title')
      if (item.mitigations.length === 0) {} else {
        item.mitigations.forEach((item, index) => {
          this.renderMitigation(item.mitigation, index)
          this.writeHtml('Bewertung des Restrisiko', 'title')
          this.renderAssessment(item.assessment)
        })
      }
      this.writeHtml('&nbsp;')
    })
  }
  
  renderAvoidanceDefinition() {
    var definitions = this.hazardAssessment.settings.get('avoidance')
    var table = new ReportTable.Table(definitions.length, 3)
    table.style = ReportTable.Table.NoBorderStyle
  
    table.horizontalHeader.style = 'tableHeader'
    table.horizontalHeader.addRow()
    table.horizontalHeader.setCaption(0, 'Häufigkeit')
    table.horizontalHeader.setCaption(1, 'Wert')
    table.horizontalHeader.setWidth(1, 50)
    table.horizontalHeader.setCaption(2, 'Vermeidbarkeit')
    for (var i = 0; i < definitions.length; i++) {
      table.setData(i, 0, definitions[i].label[this.format.locale])
      table.setData(i, 1, definitions[i].value)
      if (definitions[i].description !== undefined && definitions[i].description[this.format.locale] !== undefined) {
        table.setData(i, 2, definitions[i].description[this.format.locale])
      }
    }
    this.writeTable(table)
    this.writeHtml('&nbsp;')
  
  }
  
  renderAssessment(assessment) {
    var avoidance = this.hazardLogSettings.avoidance.find(item => item.value === assessment.avoidance)
    var frequency = this.hazardLogSettings.frequency.find(item => item.value === assessment.frequency)
    var probability = this.hazardLogSettings.probability.find(item => item.value === assessment.probability)
    var severity = this.hazardLogSettings.severity.find(item => item.value === assessment.severity)
  
    var k = avoidance.value + frequency.value + probability.value
    var risklevel = this.hazardLogSettings.risklevel.find(item => item.severity === severity.value && k >= item.criticality.min && k <= item.criticality.max)
  
    var table = new ReportTable.Table(3, 4)
  
    table.setData(0, 0, 'Risiko')
    table.setSpan(0, 1, 1, 3)
    table.setData(0, 1, risklevel === undefined ? 'ausstehend' : risklevel.label[this.format.locale] + ' (' + (severity.value * k) + ')')
  
    table.setData(1, 0, 'Schadensausmaß')
    table.setData(1, 1, severity.label[this.format.locale] + ' (' + severity.value + ')')
  
    table.setData(1, 2, 'Wahrscheinlichkeit')
    table.setData(1, 3, probability.label[this.format.locale] + ' (' + probability.value + ')')
  
    table.setData(2, 0, 'Häufigkeit')
    table.setData(2, 1, frequency.label[this.format.locale] + ' (' + frequency.value + ')')
  
    table.setData(2, 2, 'Vermeidbarkeit')
    table.setData(2, 3, avoidance.label[this.format.locale] + ' (' + avoidance.value + ')')
    this.writeTable(table)
    this.writeHtml('&nbsp;')
  }
  
  renderFrequencyDefinition() {
    var definitions = this.hazardAssessment.settings.get('frequency')
    var table = new ReportTable.Table(definitions.length, 3)
    table.style = ReportTable.Table.NoBorderStyle
  
    table.horizontalHeader.style = 'tableHeader'
    table.horizontalHeader.addRow()
    table.horizontalHeader.setCaption(0, 'Häufigkeit')
    table.horizontalHeader.setCaption(1, 'Wert')
    table.horizontalHeader.setWidth(1, 50)
    table.horizontalHeader.setCaption(2, 'Bemerkungen')
    for (var i = 0; i < definitions.length; i++) {
      table.setData(i, 0, definitions[i].label[this.format.locale])
      table.setData(i, 1, definitions[i].value)
      if (definitions[i].description !== undefined && definitions[i].description[this.format.locale] !== undefined) {
        table.setData(i, 2, definitions[i].description[this.format.locale])
      }
    }
    this.writeTable(table)
    this.writeHtml('&nbsp;')
  }
  
  renderProbabilityDefinition() {
    var definitions = this.hazardAssessment.settings.get('probability')
    var table = new ReportTable.Table(definitions.length, 3)
    table.style = ReportTable.Table.NoBorderStyle
    table.horizontalHeader.style = 'tableHeader'
  
    table.horizontalHeader.addRow()
    table.horizontalHeader.setCaption(0, 'Eintrittswahrscheinlichkeit')
    table.horizontalHeader.setCaption(1, 'Wert')
    table.horizontalHeader.setWidth(1, 50)
    table.horizontalHeader.setCaption(2, 'Bemerkungen')
    for (var i = 0; i < definitions.length; i++) {
      table.setData(i, 0, definitions[i].label[this.format.locale])
      table.setData(i, 1, definitions[i].value)
      if (definitions[i].description !== undefined && definitions[i].description[this.format.locale] !== undefined) {
        table.setData(i, 2, definitions[i].description[this.format.locale])
      }
    }
    this.writeTable(table)
    this.writeHtml('&nbsp;')
  
  }
  
  renderRisikoMatrixDefinition() {
  
  }
  
  renderSeverityDefinition() {
    var definitions = this.hazardAssessment.settings.get('severity')
    var table = new ReportTable.Table(definitions.length, 2)
    table.horizontalHeader.style = 'tableHeader'
  
    table.style = ReportTable.Table.NoBorderStyle
    table.horizontalHeader.addRow()
    table.horizontalHeader.setCaption(0, 'Schadensausmaß')
    table.horizontalHeader.setCaption(1, 'Wert')
    table.horizontalHeader.setWidth(1, 50)
    for (var i = 0; i < definitions.length; i++) {
      table.setData(i, 0, definitions[i].label[this.format.locale])
      table.setData(i, 1, definitions[i].value)
    }
    this.writeTable(table)
    this.writeHtml('&nbsp;')
  
  }
  
  renderHazard(hz, index) {
    var table = new ReportTable.Table(3, 3)
    table.style = ReportTable.Table.NoBorderStyle
    table.horizontalHeader.setWidth(0, 80)
    table.horizontalHeader.setWidth(1, 120)
    table.setData(0, 0, 'Gefährdung ' + (index + 1))
    table.setSpan(0, 0, 3)
    table.setData(0, 1, 'Systemelement')
    table.setData(1, 1, 'Gefährdungsfolge')
    table.setData(2, 1, 'Lebenszyklusphase')
    table.setData(0, 2, hz.ddo.attributes.title + ' [' + hz.ddo.puid + ']')
    table.setData(1, 2, this.hazardLogSettings['hazard.type'].find(item => item.value === hz.type).label[this.format.locale])
    var lcp = []
    hz.lifeCyclePhases.forEach(phase => {
      lcp.push(this.hazardLogSettings.lifecyclephase.find(item => item.value === phase).label[this.format.locale])
    })
    table.setData(2, 2, lcp.join(', '))
    this.writeTable(table)
    this.writeHtml('Beschreibung der Gefährdung', 'title')
    this.writeHtml(hz.description, 'paragraph')
  }
  
  renderMitigation(mitigation, index) {
    var type = this.hazardLogSettings['mitigation.typeofmeasure'].find(item => item.value === mitigation.type)
    var table = new ReportTable.Table(1, 3)
    table.style = ReportTable.Table.NoBorderStyle
    table.horizontalHeader.setWidth(0, 80)
    table.horizontalHeader.setWidth(1, 120)
    table.setData(0, 0, 'Maßnahme ' + (index + 1))
    table.setData(0, 1, 'Art der Maßnahme')
    table.setData(0, 2, type === undefined ? 'ausstehend' : type.label[this.format.locale])
    this.writeTable(table)
    this.writeHtml('Beschreibung der Maßnahme', 'title')
    this.writeHtml(mitigation.description, 'paragraph')
  
  }  /* reposyd-reportblock-body */
  static DefaultSettings() {
    return {
      /* reposyd-reportblock-settings */
      section: [
        {
          id: 'pageBreak',
          title: {
            'de-DE': 'Seitenumbruch',
            'en-US': 'Page Break'
          },
          type: 'boolean',
          value: false
        }
      ],
      reportblock: [
      ]
    }
    /* reposyd-reportblock-settings */
  }
}

module.exports = ReportBlockHazardLog

