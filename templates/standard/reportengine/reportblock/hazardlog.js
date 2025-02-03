/* reposyd-reportblock-header */
/* eslint-disable no-useless-constructor */
const { ReportFramework, Utils } = require('@reposyd/core')
/* reposyd-reportblock-header */

class ReportBlockHazardLog extends ReportFramework.ReportBlock {
  constructor (section, engine) {
    super(section, engine)
    /* reposyd-reportblock-constructor */
    this.hazardLogSettings = this.hazardAssessment.settings.get('*')
    /* reposyd-reportblock-constructor */
  }

  /* reposyd-reportblock-body */
  renderContent () {
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
      // this.writeHtml('Gefährdungsrisiko', 'title')
      this.renderAssessment(item.assessment, 'Gefährdungsrisiko: ')
      this.writeHtml('Maßnahmen zur Gefahrenminderung', 'title')
      if (item.measures.length === 0) {
        this.writeHtml('Keine Maßnahmen definert', 'paragraph')
      } else {
        item.measures.forEach((item, index) => {
          this.renderMitigation(item.mitigation, index)
          this.renderNormativeDocuments(item.mitigation)
          // this.writeHtml('Bewertung des Restrisiko', 'title')
          this.renderAssessment(item.assessment, 'Bewertung des Restrisiko: ')
        })
      }
      this.writeHtml('&nbsp;')
    })
  }

  renderAvoidanceDefinition () {
    var definitions = this.hazardAssessment.settings.get('avoidance')
    var table = new ReportFramework.ReportTable.Table(definitions.length, 3)
    table.style = ReportFramework.ReportTable.Table.NoBorderStyle

    table.horizontalHeader.setStyle(-1, 'tableHeader')
    table.horizontalHeader.addRow()
    table.horizontalHeader.setCaption(0, 'Häufigkeit')
    table.horizontalHeader.setCaption(1, 'Wert')
    table.horizontalHeader.setWidth(1, 50)
    table.horizontalHeader.setCaption(2, 'Vermeidbarkeit')
    for (var i = 0; i < definitions.length; i++) {
      table.setData(i, 0, definitions[i].label[this.document.lang])
      table.setData(i, 1, definitions[i].value)
      if (definitions[i].description !== undefined && definitions[i].description[this.document.lang] !== undefined) {
        table.setData(i, 2, definitions[i].description[this.document.lang])
      }
    }
    this.writeTable(table)
    this.writeHtml('&nbsp;')
  }

  renderAssessment (assessment, title) {
    var avoidance = this.hazardLogSettings.avoidance.find(item => item.value === assessment.avoidance)
    var frequency = this.hazardLogSettings.frequency.find(item => item.value === assessment.frequency)
    var probability = this.hazardLogSettings.probability.find(item => item.value === assessment.probability)
    var severity = this.hazardLogSettings.severity.find(item => item.value === assessment.severity)

    var k = avoidance.value + frequency.value + probability.value
    var risklevel = this.hazardLogSettings.risklevel.find(item => item.severity === severity.value && k >= item.criticality.min && k <= item.criticality.max)

    const table = new ReportFramework.ReportTable.Table(3, 4)
    table.horizontalHeader.setWidth(0, 30)
    table.horizontalHeader.setWidth(2, 30)
    table.setData(0, 0, (title || 'Risikostufe: ') + (risklevel === undefined ? 'ausstehend' : risklevel.label[this.document.lang] + ' (' + (severity.value * k) + ')'))
    table.cell(0, 0).style = 'headingMedium'
    table.setSpan(0, 0, 1, 4)
    table.setData(0, 1, risklevel === undefined ? 'ausstehend' : risklevel.label[this.document.lang] + ' (' + (severity.value * k) + ')')
    table.cell(0, 1).style = 'headingMedium'

    table.setData(1, 0, 'Schadensausmaß')
    table.setData(1, 1, severity.label[this.document.lang] + ' (' + severity.value + ')')

    table.setData(1, 2, 'Wahrscheinlichkeit')
    table.setData(1, 3, probability.label[this.document.lang] + ' (' + probability.value + ')')

    table.setData(2, 0, 'Häufigkeit')
    table.setData(2, 1, frequency.label[this.document.lang] + ' (' + frequency.value + ')')

    table.setData(2, 2, 'Vermeidbarkeit')
    table.setData(2, 3, avoidance.label[this.document.lang] + ' (' + avoidance.value + ')')
    this.writeTable(table)
    this.writeHtml('&nbsp;')
  }

  renderFrequencyDefinition () {
    var definitions = this.hazardAssessment.settings.get('frequency')
    var table = new ReportFramework.ReportTable.Table(definitions.length, 3)
    table.style = ReportFramework.ReportTable.Table.NoBorderStyle

    table.horizontalHeader.setStyle(-1, 'tableHeader')
    table.horizontalHeader.addRow()
    table.horizontalHeader.setCaption(0, 'Häufigkeit')
    table.horizontalHeader.setCaption(1, 'Wert')
    table.horizontalHeader.setWidth(1, 50)
    table.horizontalHeader.setCaption(2, 'Bemerkungen')
    for (var i = 0; i < definitions.length; i++) {
      table.setData(i, 0, definitions[i].label[this.document.lang])
      table.setData(i, 1, definitions[i].value)
      if (definitions[i].description !== undefined && definitions[i].description[this.document.lang] !== undefined) {
        table.setData(i, 2, definitions[i].description[this.document.lang])
      }
    }
    this.writeTable(table)
    this.writeHtml('&nbsp;')
  }

  renderNormativeDocuments (mn) {
    this.writeHtml('Anzuwendende Normen und Standards', 'title')
    const list = this.hazardAssessment.mitigation.normativeDocuments(mn.uuid)
    if (!list.length) {
      this.writeHtml('Keine', 'paragraph')
    } else {
      const dd = this.designDataObjectDefinition('ND')
      const table = new ReportFramework.ReportTable.Table(0, 3)
      // table.border = false
      table.horizontalHeader.setWidth(0, 50)
      Utils.Sort.byAttributes(list, [dd.attributes.number, dd.attributes.title])
        .forEach(nd => {
          const r = table.appendRow()
          r.cell(0).setData(nd.attributes.number)
          r.cell(1).setData(nd.attributes.title)
          if (nd.attributes.publicationdate && nd.attributes.revision) {
            r.cell(2).setData(nd.attributes.publicationdate + ' / ' + nd.attributes.revision)
          } else if (nd.attributes.publicationdate && !nd.attributes.revision) {
            r.cell(2).setData(nd.attributes.publicationdate)
          } else if (!nd.attributes.publicationdate && nd.attributes.revision) {
            r.cell(2).setData(nd.attributes.revision)
          }
        })
      this.writeTable(table)
    }
  }

  renderProbabilityDefinition () {
    var definitions = this.hazardAssessment.settings.get('probability')
    var table = new ReportFramework.ReportTable.Table(definitions.length, 3)
    table.style = ReportFramework.ReportTable.Table.NoBorderStyle
    table.horizontalHeader.setStyle(-1, 'tableHeader')

    table.horizontalHeader.addRow()
    table.horizontalHeader.setCaption(0, 'Eintrittswahrscheinlichkeit')
    table.horizontalHeader.setCaption(1, 'Wert')
    table.horizontalHeader.setWidth(1, 50)
    table.horizontalHeader.setCaption(2, 'Bemerkungen')
    for (var i = 0; i < definitions.length; i++) {
      table.setData(i, 0, definitions[i].label[this.document.lang])
      table.setData(i, 1, definitions[i].value)
      if (definitions[i].description !== undefined && definitions[i].description[this.document.lang] !== undefined) {
        table.setData(i, 2, definitions[i].description[this.document.lang])
      }
    }
    this.writeTable(table)
    this.writeHtml('&nbsp;')
  }

  renderRisikoMatrixDefinition () {

  }

  renderSeverityDefinition () {
    var definitions = this.hazardAssessment.settings.get('severity')
    var table = new ReportFramework.ReportTable.Table(definitions.length, 2)
    table.horizontalHeader.setStyle(-1, 'tableHeader')

    table.style = ReportFramework.ReportTable.Table.NoBorderStyle
    table.horizontalHeader.addRow()
    table.horizontalHeader.setCaption(0, 'Schadensausmaß')
    table.horizontalHeader.setCaption(1, 'Wert')
    table.horizontalHeader.setWidth(1, 50)
    for (var i = 0; i < definitions.length; i++) {
      table.setData(i, 0, definitions[i].label[this.document.lang])
      table.setData(i, 1, definitions[i].value)
    }
    this.writeTable(table)
    this.writeHtml('&nbsp;')
  }

  renderHazard (hz, index) {
    var table = new ReportFramework.ReportTable.Table(3, 3)
    table.style = ReportFramework.ReportTable.Table.NoBorderStyle
    table.horizontalHeader.setWidth(0, 80)
    table.horizontalHeader.setWidth(1, 120)
    table.setData(0, 0, 'Gefährdung ' + (index + 1))
    table.cell(0, 0).style = 'heading2'
    table.setSpan(0, 0, 3)
    table.setData(0, 1, 'Systemelement')
    table.setData(1, 1, 'Gefährdungsfolge')
    table.setData(2, 1, 'Lebenszyklusphase')
    table.setData(0, 2, hz.ddo.attributes.title + ' [' + hz.ddo.puid + ']')
    table.setData(1, 2, this.hazardLogSettings.hazardtype.find(item => item.value === hz.type).label[this.document.lang])
    var lcp = []
    hz.lifeCyclePhases.forEach(phase => {
      lcp.push(this.hazardLogSettings.lifecyclephase.find(item => item.value === phase).label[this.document.lang])
    })
    table.setData(2, 2, lcp.join(', '))
    this.writeTable(table)
    this.writeHtml('Beschreibung der Gefährdung', 'title')
    this.writeHtml(hz.description, 'paragraph')
  }

  renderMitigation (mitigation, index) {
    var type = this.hazardLogSettings.mitigationtype.find(item => item.value === mitigation.type)
    var table = new ReportFramework.ReportTable.Table(1, 3)
    table.style = ReportFramework.ReportTable.Table.NoBorderStyle
    table.horizontalHeader.setWidth(0, 80)
    table.horizontalHeader.setWidth(1, 120)
    table.setData(0, 0, 'Maßnahme ' + (index + 1))
    table.setData(0, 1, 'Art der Maßnahme')
    table.setData(0, 2, type === undefined ? 'ausstehend' : type.label[this.document.lang])
    this.writeTable(table)
    this.writeHtml('Beschreibung der Maßnahme', 'title')
    this.writeHtml(mitigation.description, 'paragraph')
  }
  /* reposyd-reportblock-body */

  static DefaultSettings () {
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
