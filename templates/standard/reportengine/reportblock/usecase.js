/* reposyd-reportblock-header */
const ReportBlock = require( 'ReportFramework' ).ReportBlock
const ReportTable = require('ReportFramework').ReportTable
const Utils = require( 'Utils' )
/* reposyd-reportblock-header */
class ReportBlockUseCase extends ReportBlock {
  constructor( section, engine ) {
    super( section, engine )
    /* reposyd-reportblock-constructor */
    this.sectionNumber = new Utils.LexicographicalOrder.SectionNumber( section.number )
    /* reposyd-reportblock-constructor */
  }
  /* reposyd-reportblock-body */
  renderContent() {
    this.format.writeHtml( this.section.text )
    this.sectionNumber.add()

    this.designDataObjects( 'UC' ).forEach( uc => {
      this.renderUseCase( uc )
    } )
  }

  renderUseCase( uc ) {
    this.addDesignData( 'ddo', uc.uuid )

    this.addSection( this.sectionNumber.toString(), uc.attributes.title )
    this.writeHtml( uc.attributes.description, 'description' )
    this.renderLinkedRequirements( uc )
  }

  renderLinkedRequirements( uc ) {
    this.writeHtml( this.tc( 'Anforderung' ), 'title' )
    var requirements = this.designDataLinks( uc, 'defines', 'RT' )
    if ( requirements.length === 0 ) {
      this.writeHtml( this.tc( 'None' ), 'description' )
    } else {
      var table = new ReportTable.Table( requirements.length + 1, 2 )
      table.style = ReportTable.Table.NoBorderStyle
      table.setData( 0, 0, 'Title' )
      table.setData( 0, 1, 'PUID' )
      var row = 1
      requirements.forEach( rt => {
        table.setData( row, 0, rt.ddo.attributes.title )
        table.setData( row, 1, rt.ddo.puid )
        table.setData( row++, 1, { target: rt.ddo.puid, type: 'destination' }, 3 )
      } )
      this.writeTable( table )
    }
  }
  /* reposyd-reportblock-body */
  static RuleDefinition( settings ) {
    var rule = ReportBlockRequirements.DefaultSettings( settings ).rule;
    return rule === undefined ? null : rule
  }
  static DefaultSettings( settings ) {
    return {
      /* reposyd-reportblock-settings */
      section: [{
        id: 'pageBreak',
        title: {
          'de-DE': 'Seitenumbruch',
          'en-US': 'Page Break'
        },
        type: 'boolean',
        value: false
      }],
      reportblock: [{
        id: 'rt.attributes.type',
        title: {
          'de-DE': 'Art der Anforderung',
          'en-US': 'Type of Requirement'
        },
        type: 'select',
        options: 'type@RT',
        selection: 'single',
        value: 'pending'
      },
      {
        id: 'verification',
        title: {
          'de-DE': 'Drucke Nachweisführung',
          'en-US': 'Print Verification'
        },
        type: 'boolean',
        value: false
      }
      ]
    }
    /* reposyd-reportblock-settings */
  }
}

module.exports = ReportBlockUseCase

